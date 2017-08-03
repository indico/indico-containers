FROM nginx

RUN rm /etc/nginx/conf.d/default.conf
COPY indico.conf /etc/nginx/conf.d/indico.conf

EXPOSE 8080

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /var/* /etc/nginx && chmod -R g+rwX /var/* /etc/nginx

CMD ["nginx", "-g", "daemon off;"]
