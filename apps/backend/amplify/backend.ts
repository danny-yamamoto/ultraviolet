import { defineBackend } from '@aws-amplify/backend';
import { CustomDatabase } from './custom/customdatabase/resource';

const backend = defineBackend({});

const customDatabase = new CustomDatabase(
  backend.createStack('CustomDatabase'),
  'CustomDatabase',
);

backend.addOutput({
  custom: {
    db: customDatabase,
  },
});
