export type Validator = ((value: any) => null | string)

// Validate some value with the passed validators
// This thows an error if the validation do not succeed
export function validate(
	value: string,
	label = "a value",
	validators: Validator[],
) {
	const validations = validators
		.map(validator => validator(value))
		.filter(result => result !== null)

	if (validations.length > 0) {
		throw {
			code: 400,
			message: new Error(
				`The property '${label}' is invalid (${validations.join()})`,
			),
		}
	}
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
