/**
 * INFRA 통합 테스트 — codes 공통코드 + CyclePhase enum
 * 시나리오: 회원가입 → JWT 획득 → GET /codes/:groupId → GET /codes?groups=
 */
process.env.JWT_SECRET = 'test-secret';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { Test } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
// eslint-disable-next-line @typescript-eslint/no-require-imports
const request = require('supertest') as typeof import('supertest');
import { AuthController } from './auth/auth.controller';
import { AuthService } from './auth/auth.service';
import { JwtStrategy } from './auth/strategies/jwt.strategy';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { CodesController } from './codes/codes.controller';
import { CodesService } from './codes/codes.service';
import { Code } from './entities/code.entity';
import { UserCycle } from './entities/user-cycle.entity';
import { User } from './entities/user.entity';
import { UsersService } from './users/users.service';

const EMAIL = `codes_${Date.now()}@test.app`;
const PW = 'Test1234!';
const NAME = 'INFRA테스터';

jest.setTimeout(30000);

describe('INFRA 통합 테스트 — 공통코드 (SQLite in-memory)', () => {
  let app: INestApplication;
  let token: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({ isGlobal: true }),
        TypeOrmModule.forRoot({
          type: 'better-sqlite3',
          database: ':memory:',
          entities: [User, UserCycle, Code],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([User, UserCycle, Code]),
        PassportModule,
        JwtModule.register({
          secret: 'test-secret',
          signOptions: { expiresIn: '1h' },
        }),
      ],
      controllers: [AuthController, CodesController],
      providers: [
        AuthService,
        UsersService,
        CodesService,
        JwtStrategy,
        JwtAuthGuard,
      ],
    }).compile();

    app = moduleRef.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();

    // 회원가입 + JWT 획득
    const reg = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: EMAIL, password: PW, name: NAME });
    token = (reg.body as { data: { access_token: string } }).data.access_token;
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /codes/mood → mood 4개 반환', async () => {
    const res = await request(app.getHttpServer())
      .get('/codes/mood')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = res.body as {
      data: Array<{
        groupId: string;
        numericValue: number;
        labels: { ko: string };
      }>;
    };
    expect(body.data).toHaveLength(4);
    expect(body.data[0].groupId).toBe('mood');
    expect(body.data[0].numericValue).toBeDefined();
    expect(body.data.map((d) => d.numericValue).sort()).toEqual([1, 2, 3, 5]);
  });

  it('GET /codes/evening_mood → evening_mood 4개 반환', async () => {
    const res = await request(app.getHttpServer())
      .get('/codes/evening_mood')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = res.body as { data: Array<{ groupId: string }> };
    expect(body.data).toHaveLength(4);
    expect(body.data[0].groupId).toBe('evening_mood');
  });

  it('GET /codes/goal_option → goal_option 4개 반환 + metadata 포함', async () => {
    const res = await request(app.getHttpServer())
      .get('/codes/goal_option')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = res.body as {
      data: Array<{ groupId: string; metadata: Record<string, string> }>;
    };
    expect(body.data).toHaveLength(4);
    expect(body.data[0].metadata).toHaveProperty('accent_color');
    expect(body.data[0].metadata).toHaveProperty('subtitle');
  });

  it('GET /codes?groups=mood,evening_mood → 배치 응답', async () => {
    const res = await request(app.getHttpServer())
      .get('/codes?groups=mood,evening_mood')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = res.body as {
      data: { mood: unknown[]; evening_mood: unknown[] };
    };
    expect(body.data).toHaveProperty('mood');
    expect(body.data).toHaveProperty('evening_mood');
    expect(body.data.mood).toHaveLength(4);
    expect(body.data.evening_mood).toHaveLength(4);
  });

  it('GET /codes/mood → displayOrder 오름차순 정렬', async () => {
    const res = await request(app.getHttpServer())
      .get('/codes/mood')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = res.body as { data: Array<{ displayOrder: number }> };
    const orders = body.data.map((d) => d.displayOrder);
    expect(orders).toEqual([...orders].sort((a, b) => a - b));
  });

  it('GET /codes/mood — 비로그인 public 접근 200 (가드 제거됨)', async () => {
    const res = await request(app.getHttpServer())
      .get('/codes/mood')
      .expect(200);
    const body = res.body as { data: unknown[] };
    expect(body.data).toHaveLength(4);
  });
});
