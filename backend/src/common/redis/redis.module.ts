import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Redis } from 'ioredis';
import { REDIS_CLIENT } from './redis.constants';
import { TokenBlacklistService } from './token-blacklist.service';

@Global()
@Module({
  providers: [
    {
      provide: REDIS_CLIENT,
      useFactory: (config: ConfigService): Redis => {
        const url = config.get<string>('REDIS_URL', 'redis://localhost:6379');
        // lazyConnect: 부팅 시 연결하지 않아 Redis 장애가 앱 기동을 막지 않는다.
        return new Redis(url, { lazyConnect: true, maxRetriesPerRequest: 2 });
      },
      inject: [ConfigService],
    },
    TokenBlacklistService,
  ],
  exports: [TokenBlacklistService],
})
export class RedisModule {}
