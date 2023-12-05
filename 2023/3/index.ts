import { getLinesFromInput } from "../../utils.ts";

export async function partOne() {
	let runningTotal = 0;
	const lines = await getLinesFromInput();

	for (const [y, line] of Object.entries(lines)) {
		let currentNumber;
		const numberMatch = new RegExp("\\.*(?<number>\\d+)\\.*?", "g");

		numberLoop: while ((currentNumber = numberMatch.exec(line)?.[1])) {
			const { lastIndex: end } = numberMatch;
			const start = end - currentNumber.length;

			for (let x = start; x < end; x++) {
				for (const [relY, relX] of coords) {
					const targetLine = lines[Number(y) + relY]?.split("");
					if (!targetLine) continue;

					const targetCell = targetLine[x + relX];

					if (
						!targetCell ||
						digitPattern.test(targetCell) ||
						targetCell === gap
					) {
						continue;
					}

					runningTotal += Number(currentNumber);
					continue numberLoop;
				}
			}
		}
	}
	return runningTotal;
}

export async function partTwo() {
	let runningTotal = 0;
	const lines = await getLinesFromInput();

	for (const [y, line] of Object.entries(lines)) {
		const asteriskMatch = new RegExp("\\.*(?<asterisk>\\*+)\\.*?", "g");

		asteriskLoop: while (asteriskMatch.exec(line)?.[1]) {
			const gearNumbers = new Map<string, number>();
			const index = asteriskMatch.lastIndex - 1;

			for (const [relY, relX] of coords) {
				const targetLine = lines[Number(y) + relY]?.split("");
				if (!targetLine) continue;

				const targetCell = targetLine[index + relX];
				if (!digitPattern.test(targetCell)) continue;

				const [currentNumber, leftIndex, rightIndex] = walkOutward(
					targetLine,
					index + relX,
				);

				const key = `${targetLine.join()}${leftIndex}${rightIndex}`;
				if (!gearNumbers.has(key)) gearNumbers.set(key, currentNumber);
				if (gearNumbers.size === 2) {
					const [num1, num2] = Array.from(gearNumbers.values());
					runningTotal += num1 * num2;
					continue asteriskLoop;
				}
			}
		}
	}
	return runningTotal;
}

function walkOutward(line: string[], index: number): [number, number, number] {
	let number = line[index];
	let leftIndex = index - 1;
	let rightIndex = index + 1;
	let left, right;
	while (digitPattern.test((left = line[leftIndex--]))) {
		number = left + number;
	}

	while (digitPattern.test((right = line[rightIndex++]))) {
		number = number + right;
	}
	return [Number(number), leftIndex, rightIndex];
}

const digitPattern = /\d/;

const gap = ".";

const coords = [
	[-1, -1],
	[-1, 0],
	[-1, 1],
	[0, -1],
	[0, 1],
	[1, -1],
	[1, 0],
	[1, 1],
] as const;
