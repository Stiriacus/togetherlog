// Input validation utilities

export interface ValidationError {
  field: string
  message: string
}

export class ValidationException extends Error {
  errors: ValidationError[]

  constructor(errors: ValidationError[]) {
    super('Validation failed')
    this.errors = errors
  }
}

export function validateRequired(value: unknown, fieldName: string): void {
  if (value === undefined || value === null || value === '') {
    throw new ValidationException([{ field: fieldName, message: `${fieldName} is required` }])
  }
}

export function validateString(value: unknown, fieldName: string, minLength = 1, maxLength = 255): void {
  validateRequired(value, fieldName)

  if (typeof value !== 'string') {
    throw new ValidationException([{ field: fieldName, message: `${fieldName} must be a string` }])
  }

  if (value.length < minLength) {
    throw new ValidationException([{ field: fieldName, message: `${fieldName} must be at least ${minLength} characters` }])
  }

  if (value.length > maxLength) {
    throw new ValidationException([{ field: fieldName, message: `${fieldName} must be at most ${maxLength} characters` }])
  }
}

export function validateEnum<T extends string>(value: unknown, fieldName: string, allowedValues: T[]): void {
  validateRequired(value, fieldName)

  if (!allowedValues.includes(value as T)) {
    throw new ValidationException([{
      field: fieldName,
      message: `${fieldName} must be one of: ${allowedValues.join(', ')}`
    }])
  }
}

export function validateUUID(value: unknown, fieldName: string): void {
  validateRequired(value, fieldName)

  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  if (!uuidRegex.test(value as string)) {
    throw new ValidationException([{ field: fieldName, message: `${fieldName} must be a valid UUID` }])
  }
}
