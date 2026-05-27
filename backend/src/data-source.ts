import { join } from 'path';
import { DataSource } from 'typeorm';

// 로컬 CLI는 .env에서 DB 접속정보를 읽는다. 운영 컨테이너는 dotenv(devDep) 미설치 +
// docker-compose가 process.env를 주입하므로 dotenv 없이 동작 → optional load.
try {
  require('dotenv').config();
} catch {
  // dotenv 미설치(운영 --omit=dev) — process.env 사용
}

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
