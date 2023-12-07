import { getInput } from "../../utils.ts";

export async function partOne() {
	return getInput().then((input) => {
		const sections = input.split("\n\n");
		const seeds = sections[0].split(": ")[1].split(" ").map(Number);
		const lookups = sections.slice(1).map((section) => {
			const [header, ...table] = section.split("\n");
			const [name] = header.split(" ");
			return new Lookup(name, table);
		});
		const locations = seeds
			.slice(0)
			.map((seed) =>
				lookups.reduce(
					(currentValue, lookup) => lookup.get(currentValue),
					seed,
				),
			);
		return Math.min(...locations);
	});
}

export async function partTwo() {}

class Lookup {
	name: string;
	table: Row[];

	constructor(name: string, table: string[]) {
		this.name = name;
		this.table = table.map((row) => new Row(row.split(" ").map(Number)));
	}

	get(startingValue: number) {
		const row = this.table.find((row) => {
			const { min, max } = row.sourceRange;
			return min <= startingValue && startingValue <= max;
		});
		const newValue = row
			? row.destination + startingValue - row.source
			: startingValue;
		return newValue;
	}
}

class Row {
	row: number[];
	destination: number;
	source: number;
	range: number;

	constructor(row: number[]) {
		this.row = row;
		this.destination = row[0];
		this.source = row[1];
		this.range = row[2];
	}

	get sourceRange() {
		return { min: this.source, max: this.source + this.range - 1 };
	}

	get destinationRange() {
		return { min: this.destination, max: this.destination + this.range - 1 };
	}
}
