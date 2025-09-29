from indico.web.flask.app import make_app


def _create_user(db):
    """Create and admin user in order to skip the manual /bootstrap setup"""
    from indico.core.config import config
    from indico.modules.auth import Identity
    from indico.modules.users import User

    user = User()
    user.first_name = "John"
    user.last_name = "Doe"
    user.affiliation = "CERN"
    user.email = "john.doe@example.com"
    user.is_admin = True

    identity = Identity(provider='indico', identifier="admin", password="indiko42")
    user.identities.add(identity)

    db.session.add(user)
    db.session.flush()

    user.settings.set('timezone', config.DEFAULT_TIMEZONE)
    user.settings.set('lang', config.DEFAULT_LOCALE)
    db.session.commit()


def _create_announcement(db):
    from indico.modules.announcement import announcement_settings

    message = ('THIS INSTANCE IS MEANT TO BE USED FOR DEVELOPMENT AND TESTING ONLY. '
               'DO NOT USE IT IN PRODUCTION OR ON ANY PUBLICLY ACCESSIBLE SERVER!')
    announcement_settings.set_multi({ 'enabled': True, 'message': message })
    db.session.flush()
    db.session.commit()


with make_app().app_context():
    from indico.core.db import db

    print("Creating an admin user...")
    _create_user(db)
    print("Creating an announcement...")
    _create_announcement(db)
