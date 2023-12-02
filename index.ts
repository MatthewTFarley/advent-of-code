const [year, day, part] = process.argv.slice(2);

const { partOne, partTwo } = (await import(`./${year}/${day}/index.ts`)) as {
  partOne: () => Promise<unknown>;
  partTwo: () => Promise<unknown>;
};

if (!["1", "2"].includes(part)) {
  throw new Error(`invalid part "${part}". Must be "1" or "2"`);
}

const func = part === "1" ? partOne : partTwo;

console.log(await func());
