import { readFile } from "node:fs/promises";
import path from "node:path";

const [year, day, , filename] = process.argv.slice(2);

export async function getInput(): Promise<string> {
  const filepath = path.join(process.cwd(), `${year}/${day}/${filename}`);
  return (await readFile(filepath)).toString();
}

export async function getLinesFromInput() {
  const input = await getInput();
  return input.trimEnd().split("\n");
}
