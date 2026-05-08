export class ApiResponse<T> {
  data: T;

  static success<T>(data: T): ApiResponse<T> {
    const res = new ApiResponse<T>();
    res.data = data;
    return res;
  }
}
