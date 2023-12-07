import { multiply, zip } from "ramda";
import { getLinesFromInput } from "../../utils.ts";

export async function partOne() {
	return getLinesFromInput().then((lines) => {
		const [times, distances] = lines.map((line) =>
			line.split(/:\s+/)[1].split(/\s+/).map(Number),
		);
		return zip(times, distances).map(findSuccesses).reduce(multiply, 1);
	});
}

export async function partTwo() {
	return getLinesFromInput().then(([line1, line2]) => {
		const [time, distance] = [line1, line2].map(joinAsNumber);
		return findSuccesses([time, distance]);
	});
}

function joinAsNumber(line: string): number {
	return Number(line.split(/:\s+/)[1].split(/\s+/).join(""));
}

function findSuccesses([time, distance]: [number, number]): number {
	let successCount = 0;
	for (let i = 0; i < time; i++) {
		if (i * (time - i) > distance) {
			successCount++;
		}
	}
	return successCount;
}
