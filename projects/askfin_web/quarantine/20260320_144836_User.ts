export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: number;
}

export type UserId = string & { readonly __brand: 'UserId' };