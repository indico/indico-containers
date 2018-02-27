import json
import os
import subprocess as sb
import sys

import click


@click.command()
@click.option('--url', default=None, help='URL of the openshift cluster')
@click.option('--token', default=None, help='Session token used to authenticate in the cluster')
@click.option('--project', default=None, help='Context project')
def run_deploy_with_db_upgrade(url, token, project):
    if url and token:
        cmd = sb.Popen(['oc', 'login', url, '--token', token], stdout=sb.PIPE, stderr=sb.STDOUT)
        output = cmd.communicate()
        if cmd.returncode != 0:
            click.echo(click.style(output[0], fg='red'))
            sys.exit(cmd.returncode)

    if project is not None:
        cmd = sb.Popen(['oc', 'project', project], stdout=sb.PIPE, stderr=sb.STDOUT)
        output = cmd.communicate()
        if cmd.returncode != 0:
            click.echo(click.style(output[0], fg='red'))
            sys.exit(cmd.returncode)

    hpa = sb.check_output('oc get hpa/indico-web-autoscaler -o json --export'.split())
    indico_dc = sb.check_output('oc get dc/indico -o json --export'.split())
    commands = [
        {
            'label': 'Deleting HPA',
            'cmds': ['oc delete hpa/indico-web-autoscaler'.split()],
            'input': None
        }, {
            'label': 'Tagging Indico to indico:tmp',
            'cmds': ['oc tag indico:latest indico:previous'.split()],
            'input': None
        }, {
            'label': 'Creating temporary DC',
            'cmds': ['oc create -f -'.split()],
            'input': [modify_dc_data(indico_dc)]
        }, {
            'label': 'Rolling out the temporary Indico DC',
            'cmds': ['oc rollout latest dc/indico-tmp'.split(), 'oc rollout status dc/indico-tmp'.split()],
            'input': None
        }, {
            'label': 'Patching the indico-web SVC',
            'cmds': [['oc', 'patch', 'svc', 'indico-web', '-p',
                      '{"spec": {"selector": {"indico.web.service": "indico-web-tmp"}}}']],
            'input': None
        }, {
            'label': 'Scaling dc/indico to 1 replica',
            'cmds': ['oc scale dc/indico --replicas=1'.split()],
            'input': None
        }, {
            'label': 'Building the latest version of the Indico image',
            'cmds': ['oc start-build indico --wait'.split(), 'oc rollout status dc/indico'.split()],
            'input': None
        }, {
            'label': 'Indico db upgrade via rsh',
            'cmds': ['oc rsh dc/indico /opt/indico/.venv/bin/indico db upgrade'.split()],
            'input': None
        }, {
            'label': 'Patching the service to the previous state',
            'cmds': [['oc', 'patch', 'svc', 'indico-web', '-p', 
                      '{"spec": {"selector": {"indico.web.service": "indico-web"}}}']],
            'input': None
        }, {
            'label': 'Restoring HPA',
            'cmds': ['oc create -f -'.split()],
            'input': [hpa]
        }, {
            'label': 'Deleting temporary DC',
            'cmds': ['oc delete dc/indico-tmp'.split()],
            'input': None
        }, {
            'label': 'Deleting temporary tag',
            'cmds': ['oc tag indico:previous -d'.split()],
            'input': None
        }, {
            'label': 'Logging out',
            'cmds': ['oc logout'.split()],
            'input': None
        }
    ]

    def item_show_func(item):
        return click.style(item['label'], fg='green') if item else None

    with open(os.devnull, 'w') as devnull:
        with click.progressbar(commands, show_eta=False, show_pos=True, item_show_func=item_show_func) as progress:
            for cmd in progress:
                for index, cmd_it in enumerate(cmd['cmds']):
                    cmd_input = None
                    cmd_kwargs = {}
                    if cmd['input']:
                        cmd_input = cmd['input'][index]
                        cmd_kwargs = {'stdin': sb.PIPE}
                    sb.Popen(cmd_it, stdout=devnull, **cmd_kwargs).communicate(input=cmd_input)
    click.echo(click.style('Done!', fg='green'))


def modify_dc_data(data):
    dc_data = json.loads(data)
    dc_data['metadata']['labels']['indico.web.service'] = 'indico-web-tmp'
    dc_data['metadata']['name'] = 'indico-tmp'
    dc_data['spec']['selector']['indico.web.service'] = 'indico-web-tmp'
    dc_data['spec']['template']['metadata']['labels']['indico.web.service'] = 'indico-web-tmp'
    dc_data['spec']['template']['spec']['containers'][0]['image'] = ' '
    dc_data['spec']['triggers'][1]['imageChangeParams']['automatic'] = False
    dc_data['spec']['triggers'][1]['imageChangeParams']['from']['name'] = 'indico:previous'
    return json.dumps(dc_data)


if __name__ == '__main__':
    run_deploy_with_db_upgrade()
