#!/bin/bash

psql -U ${POSTGRES_USER} <<-END
    CREATE USER ${DB_ANON_ROLE} WITH SUPERUSER;
END
