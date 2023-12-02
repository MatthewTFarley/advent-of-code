import { getLinesFromInput } from "../../utils.ts";
import { identity, reverse } from "ramda";

export async function partOne(): Promise<number> {
  return findTotal();
}

export async function partTwo(): Promise<number> {
  return findTotal((line) => {
    return [
      ["one", "one1one"],
      ["two", "two2two"],
      ["three", "three3three"],
      ["four", "four4four"],
      ["five", "five5five"],
      ["six", "six6six"],
      ["seven", "seven7seven"],
      ["eight", "eight8eight"],
      ["nine", "nine9nine"],
    ].reduce(
      (line, [target, replacement]) => line.replaceAll(target, replacement),
      line,
    );
  });
}

async function findTotal(
  processLine: (line: string) => string = identity,
): Promise<number> {
  const lines = await getLinesFromInput();

  return lines.reduce((runningTotal: number, line: string) => {
    const matches = Array.from(
      processLine(line).matchAll(/(1|2|3|4|5|6|7|8|9)/g),
    );
    const [[first]] = matches;
    const [[last]] = reverse(matches);
    return runningTotal + Number(`${first}${last}`);
  }, 0);
}
