import {
  registerDecorator,
  ValidationArguments,
  ValidationOptions,
} from 'class-validator';

// 현재 시각 기준 허용 윈도우. "당일 ±1일"을 타임존(KST/UTC 자정 경계) 영향 없이
// 처리하기 위해 캘린더 day 비교 대신 now 기준 ±36h 롤링 윈도우를 사용한다(M-4).
const WINDOW_MS = 36 * 60 * 60 * 1000;

/**
 * 날짜/일시 문자열이 현재 시각 ±36시간 이내인지 검증한다.
 * 형식 검증은 @IsDateString이 담당하므로, 여기서는 범위만 본다.
 */
export function IsWithinRecentRange(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string): void {
    registerDecorator({
      name: 'isWithinRecentRange',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: unknown): boolean {
          if (typeof value !== 'string') return false;
          const t = Date.parse(value);
          if (Number.isNaN(t)) return false;
          return Math.abs(t - Date.now()) <= WINDOW_MS;
        },
        defaultMessage(args: ValidationArguments): string {
          return `${args.property}는 현재 시각 기준 ±36시간 이내여야 합니다`;
        },
      },
    });
  };
}
