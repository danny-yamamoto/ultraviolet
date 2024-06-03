import { defineBackend } from '@aws-amplify/backend';
import { CustomDatabase } from './custom/customdatabase/resource';
import { data } from './data/resource';

const backend = defineBackend({ data });

const customDatabase = new CustomDatabase(
  backend.createStack('CustomDatabase'),
  'CustomDatabase',
);

backend.addOutput({
  custom: {
    db: customDatabase,
  },
});
