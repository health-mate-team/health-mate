import { MigrationInterface, QueryRunner } from 'typeorm';

export class Baseline1779865969779 implements MigrationInterface {
  name = 'Baseline1779865969779';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "walk_sessions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "startedAt" TIMESTAMP NOT NULL, "endedAt" TIMESTAMP, "durationMinutes" integer, "stepsCount" integer NOT NULL DEFAULT '0', "distanceKm" numeric(6,2) NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_2bb7cf78c7db6c1a1fc7f127f17" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "workout_logs" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "workoutId" character varying NOT NULL, "date" character varying NOT NULL, "workoutType" character varying NOT NULL, "durationActualMinutes" integer, "completionRate" numeric(3,2) NOT NULL DEFAULT '1', "isSkipped" boolean NOT NULL DEFAULT false, "skipReason" character varying(50), "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_53a1e174f32d705c6471f3ae7fe" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "xp_logs" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "date" date NOT NULL, "amount" integer NOT NULL, "source" character varying NOT NULL, "description" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_c3f423a3014299a7c3707f95ab9" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "user_cycles" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "lastPeriodStartDate" date NOT NULL, "averageCycleLength" integer NOT NULL DEFAULT '28', "averagePeriodLength" integer NOT NULL DEFAULT '5', "isIrregular" boolean NOT NULL DEFAULT false, "goalType" character varying NOT NULL DEFAULT 'energy', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "REL_a17d0c1d295bfb3499491a1135" UNIQUE ("userId"), CONSTRAINT "PK_838fdba6dec7d1902fa0ddd0aed" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "users" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "email" character varying NOT NULL, "password" character varying NOT NULL, "name" character varying NOT NULL, "isOnboardingCompleted" boolean NOT NULL DEFAULT false, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE ("email"), CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "meal_log_items" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "mealLogId" character varying NOT NULL, "foodId" character varying NOT NULL, "foodName" character varying NOT NULL, "amountG" integer NOT NULL, "calories" integer NOT NULL DEFAULT '0', "proteinG" numeric(6,2) NOT NULL DEFAULT '0', CONSTRAINT "PK_0203e48baefa7425ec8b3800a2c" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "daily_stats" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "date" date NOT NULL, "energyScore" numeric(5,2) NOT NULL DEFAULT '50', "hydrationScore" numeric(5,2) NOT NULL DEFAULT '50', "moodScore" numeric(5,2) NOT NULL DEFAULT '50', "restScore" numeric(5,2) NOT NULL DEFAULT '50', "waterCups" integer NOT NULL DEFAULT '0', "totalXp" integer NOT NULL DEFAULT '0', "level" integer NOT NULL DEFAULT '1', "streak" integer NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_d1830b57aa5fafc5cb26a09aa73" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "codes" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "group_id" character varying NOT NULL, "display_order" integer NOT NULL DEFAULT '0', "labels" text NOT NULL DEFAULT '{}', "emoji" character varying, "numeric_value" integer, "metadata" text NOT NULL DEFAULT '{}', "is_active" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_9b85c624e2d705f4e8a9b64dbf4" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "daily_rituals" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "date" date NOT NULL, "morningMood" integer, "morningMoodAt" text, "morningPromise" text, "morningPromiseAt" text, "eveningCompleted" boolean NOT NULL DEFAULT false, "eveningCompletedAt" text, "promiseKept" boolean NOT NULL DEFAULT false, "xpEarned" integer NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_8f514701ea295c3ae9e06d88603" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "user_badges" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "badgeCode" character varying NOT NULL, "earnedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_0ca139216824d745a930065706a" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "meal_logs" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" character varying NOT NULL, "date" character varying NOT NULL, "mealType" character varying NOT NULL, "totalCalories" integer NOT NULL DEFAULT '0', "totalProteinG" numeric(6,2) NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_ce7e6e4887e80f6a12f0f6a166a" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_cycles" ADD CONSTRAINT "FK_a17d0c1d295bfb3499491a11351" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "user_cycles" DROP CONSTRAINT "FK_a17d0c1d295bfb3499491a11351"`,
    );
    await queryRunner.query(`DROP TABLE "meal_logs"`);
    await queryRunner.query(`DROP TABLE "user_badges"`);
    await queryRunner.query(`DROP TABLE "daily_rituals"`);
    await queryRunner.query(`DROP TABLE "codes"`);
    await queryRunner.query(`DROP TABLE "daily_stats"`);
    await queryRunner.query(`DROP TABLE "meal_log_items"`);
    await queryRunner.query(`DROP TABLE "users"`);
    await queryRunner.query(`DROP TABLE "user_cycles"`);
    await queryRunner.query(`DROP TABLE "xp_logs"`);
    await queryRunner.query(`DROP TABLE "workout_logs"`);
    await queryRunner.query(`DROP TABLE "walk_sessions"`);
  }
}
