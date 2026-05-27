import {
  Inject,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import type { Redis } from 'ioredis';
import { REDIS_CLIENT } from './redis.constants';

const logoutKey = (userId: string): string => `logout:${userId}`;

// refresh 토큰 최대 수명(30일)과 동일하게 유지 — 그 이후 발급 토큰은 어차피 만료됨.
const LOGOUT_TTL_SEC = 30 * 24 * 60 * 60;

/**
 * 로그아웃 시점(epoch sec)을 사용자별로 기록해, 그 이전에 발급된(iat) access·refresh
 * 토큰을 일괄 무효화한다(H-3). 클라이언트가 refresh 토큰을 저장하지 않으므로
 * 토큰 본문이 아닌 발급시각(iat) 기준으로 무효화한다.
 *
 * Redis 장애 시 동작은 의도적으로 비대칭이다(아래 각 메서드 주석 참조). 읽기/쓰기
 * fail 모드의 비대칭을 "일관성"을 이유로 통일하지 말 것.
 */
@Injectable()
export class TokenBlacklistService {
  private readonly logger = new Logger(TokenBlacklistService.name);

  constructor(@Inject(REDIS_CLIENT) private readonly redis: Redis) {}

  /**
   * 쓰기 경로 — fail-closed. Redis 장애 시 503을 던진다.
   * 그렇지 않으면 사용자가 "로그아웃됨"으로 오인하지만 토큰은 계속 유효해진다.
   */
  async invalidateUser(userId: string): Promise<void> {
    const nowSec = Math.floor(Date.now() / 1000);
    try {
      await this.redis.set(logoutKey(userId), nowSec, 'EX', LOGOUT_TTL_SEC);
    } catch (err) {
      this.logger.error(
        `로그아웃 무효화 실패 (userId=${userId})`,
        err as Error,
      );
      throw new ServiceUnavailableException('로그아웃 처리에 실패했습니다');
    }
  }

  /**
   * 읽기 경로 — fail-open. Redis 장애 시 false(로그 후)를 반환한다.
   * 그렇지 않으면 일시적 Redis 장애가 모든 인증 요청을 500으로 만든다.
   * 블랙리스트는 방어심화 계층이며 토큰 자체에도 만료가 존재한다.
   */
  async isInvalidated(userId: string, iat?: number): Promise<boolean> {
    if (iat === undefined) return false;
    try {
      const raw = await this.redis.get(logoutKey(userId));
      if (!raw) return false;
      return iat < Number(raw);
    } catch (err) {
      this.logger.warn(
        `블랙리스트 조회 실패 (userId=${userId}) — fail-open`,
        err as Error,
      );
      return false;
    }
  }
}
