export type Validator = ((value: any) => null | string)

export function validate(value: string, validators: Validator[]) {
	return validators
		.map(validator => validator(value))
		.filter(result => result !== null)
}

export function minLengthValidator(number: number): Validator {
	return (value: string) =>
		value.length < number ? "The value is too short" : null
}

export function maxLengthValidator(number: number): Validator {
	return (value: string) =>
		value.length > number ? "The value is too long" : null
}

export function requiredValidator(value: any) {
	return value === undefined || value === null
		? "The value is not defined"
		: null
}
