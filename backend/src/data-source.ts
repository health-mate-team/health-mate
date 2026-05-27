import 'dotenv/config';
import { join } from 'path';
import { DataSource } from 'typeorm';

// CLI(migration:generate/run/revert)와 런타임이 공유하는 standalone DataSource.
// glob은 __dirname 기준이라 ts-node 실행 시 src/, 컴파일 후 dist/로 분리 해석된다.
export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 5432),
  username: process.env.DB_USER ?? 'healthmate',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME ?? 'health_mate',
  entities: [join(__dirname, 'entities', '*.entity.{ts,js}')],
  migrations: [join(__dirname, 'migrations', '*.{ts,js}')],
  synchronize: false,
});
