import { construct, map, pluck, prop as getProp, sum } from "ramda";
import { getLinesFromInput } from "../../utils.ts";

export function partOne(): Promise<Games["possibleGameIdsSum"]> {
  return buildGames().then(getProp("possibleGameIdsSum"));
}

export function partTwo(): Promise<Games["powersSum"]> {
  return buildGames().then(getProp("powersSum"));
}

async function buildGames(): Promise<Games> {
  return getLinesFromInput().then(construct(Games));
}

class Games {
  games: Game[];

  constructor(lines: string[]) {
    this.games = map(construct(Game), lines);
  }

  get possibleGameIdsSum(): number {
    return sum(this.possibleGameIds);
  }

  get powersSum(): number {
    return sum(this.powers);
  }

  private get possibleGameIds(): number[] {
    return pluck("id", this.possibleGames);
  }

  private get possibleGames(): Game[] {
    return this.games.filter(getProp("isPossible"));
  }

  private get powers(): number[] {
    return pluck("power", this.games);
  }
}

class Game {
  reveals: string[];
  id: number;
  reds: number[];
  greens: number[];
  blues: number[];

  constructor(line: string) {
    const [gameIdSide, allReveals] = line.split(": ");
    this.reveals = allReveals.split(";");
    this.id = Number(gameIdSide.split(" ")[1]);
    this.reds = this.getRevealedCount(Color.red);
    this.greens = this.getRevealedCount(Color.green);
    this.blues = this.getRevealedCount(Color.blue);
  }

  get power(): number {
    return this.maxRed * this.maxGreen * this.maxBlue;
  }

  get isImpossible(): boolean {
    return (
      this.maxRed > ColorLimit.red ||
      this.maxGreen > ColorLimit.green ||
      this.maxBlue > ColorLimit.blue
    );
  }

  get isPossible(): boolean {
    return !this.isImpossible;
  }

  get maxRed(): number {
    return Math.max(...this.reds);
  }

  get maxGreen(): number {
    return Math.max(...this.greens);
  }

  get maxBlue(): number {
    return Math.max(...this.blues);
  }

  private getRevealedCount(color: Color): number[] {
    return this.reveals.map((reveal) => {
      const match = this.getColorPattern(color).exec(reveal);
      return this.getNumberFromMatch(match);
    });
  }

  private getColorPattern(color: Color): RegExp {
    return new RegExp(`(\\d+) ${color}.*`);
  }

  private getNumberFromMatch(match: RegExpExecArray | null): number {
    return Number(match?.[1] ?? 0);
  }
}

enum Color {
  red = "red",
  green = "green",
  blue = "blue",
}

enum ColorLimit {
  red = 12,
  green = 13,
  blue = 14,
}
