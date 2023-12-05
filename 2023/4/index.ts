import { add, intersection, multiply } from "ramda";
import { getLinesFromInput } from "../../utils.ts";

export async function partOne() {
	return await getLinesFromInput().then((lines) =>
		lines
			.map((line) => {
				const [, numbers] = line.split(/:\s+/);
				const [winners, mine] = numbers
					.split(" | ")
					.map((str) => str.split(/\s+/).map(Number));
				const result = intersection(winners, mine);
				return result.length > 0
					? result.slice(1).reduce((num) => multiply(num, 2), 1)
					: 0;
			})
			.reduce(add, 0),
	);
}

export async function partTwo() {
	return await getLinesFromInput().then((lines) => {
		const winnersList = lines.map((line) => {
			const [, numbers] = line.split(/:\s+/);
			const [winnersList, mine] = numbers
				.split(" | ")
				.map((str) => str.split(/\s+/).map(Number));
			return intersection(winnersList, mine);
		});
		const tally = winnersList.reduce(
			(lookup, _, i) => {
				lookup[i] = 1;
				return lookup;
			},
			{} as Record<string, number>,
		);
		winnersList.forEach((winners, i) => {
			winners.forEach((_, j) => (tally[i + j + 1] += tally[i]));
		});
		return Object.values(tally).reduce(add, 0);
	});
}
