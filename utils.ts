import { readFile } from "node:fs/promises";
import path from "node:path";

const [year, day, part, filename] = process.argv.slice(2);

export async function getInput(): Promise<string> {
	const filepath = path.join(process.cwd(), `${year}/${day}/${filename}`);
	return (await readFile(filepath)).toString();
}

export async function getLinesFromInput() {
	const input = await getInput();
	return input.trimEnd().split("\n");
}

export async function runPuzzleFunction(): Promise<unknown> {
	const { partOne, partTwo } = (await import(`./${year}/${day}/index.ts`)) as {
		partOne: () => Promise<unknown>;
		partTwo: () => Promise<unknown>;
	};

	if (["1", "2"].includes(part)) {
		return (part === "1" ? partOne : partTwo)();
	}

	throw new Error(
		`Invalid part "${part}" provided. Part must be either "1" or "2".`,
	);
}
