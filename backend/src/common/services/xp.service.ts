import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DailyStat } from '../../entities/daily-stat.entity';
import { XpLog } from '../../entities/xp-log.entity';
import { calculateLevel } from '../utils/xp-level.util';
import { localDateString } from '../../cycle/cycle.service';

@Injectable()
export class XpService {
  constructor(
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(XpLog)
    private readonly xpLogRepo: Repository<XpLog>,
  ) {}

  async addXp(
    userId: string,
    stat: DailyStat,
    amount: number,
    source: string,
    description: string,
  ): Promise<void> {
    stat.totalXp = Number(stat.totalXp) + amount;
    stat.level = calculateLevel(stat.totalXp);
    await this.statRepo.save(stat);

    const log = this.xpLogRepo.create({
      userId,
      date: localDateString(),
      amount,
      source,
      description,
    });
    await this.xpLogRepo.save(log);
  }
}
