class ReportRepairBase {
  buildLookup() {
    throw new Error(
      'Abstract method. "buildLookup" must be implemented in child class.'
    );
  }

  extractInput() {
    this.numbers =
      this.numbers ||
      require("fs")
        .readFileSync(require("path").join(__dirname, "input.txt"))
        .toString()
        .split("\n")
        .map((line) => +line);
  }

  prepare() {
    this.extractInput();
    this.buildLookup();
  }
}

class ReportRepairComboSizeTwo extends ReportRepairBase {
  buildLookup() {
    this.lookup =
      this.lookup ||
      this.numbers.reduce(
        (acc, num) => ({
          ...acc,
          [num]: 2020 - num,
        }),
        {}
      );
  }

  get product() {
    this._product =
      this._product ||
      (() => {
        this.prepare();

        const addend1 = this.numbers.find((num) => this.lookup[2020 - num]);
        const addend2 = this.lookup[addend1];
        return addend1 * addend2;
      })();

    return this._product;
  }
}

class ReportRepairComboSizeThree extends ReportRepairBase {
  buildLookup() {
    this.lookup =
      this.lookup ||
      this.numbers.reduce(
        (acc, num) => ({
          ...acc,
          [num]: this.numbers.reduce(
            (acc2, num2) => ({
              ...acc2,
              [num2]: 2020 - num - num2,
            }),
            {}
          ),
        }),
        {}
      );
  }

  get product() {
    this._product =
      this._product ||
      (() => {
        this.prepare();

        let addend1;
        let addend2;
        let addend3;

        this.numbers.forEach((num) =>
          this.numbers.forEach((num2) => {
            if (this.lookup[num] && this.lookup[num][2020 - num - num2]) {
              if (num * num2 * (2020 - num - num2) > 0) {
                addend1 = num;
                addend2 = num2;
                addend3 = 2020 - num - num2;
              }
            }
          })
        );
        return addend1 * addend2 * addend3;
      })();

    return this._product;
  }
}

(function main(comboSize) {
  const COMBO_SIZE_TO_REPAIR_CLASS_MAP = new Map();
  COMBO_SIZE_TO_REPAIR_CLASS_MAP.set(2, ReportRepairComboSizeTwo);
  COMBO_SIZE_TO_REPAIR_CLASS_MAP.set(3, ReportRepairComboSizeThree);

  try {
    const ReportRepair = COMBO_SIZE_TO_REPAIR_CLASS_MAP.get(comboSize);
    !ReportRepair && throwError(comboSize);
    const product = new ReportRepair().product;
    Number.isNaN(product) ? logNotFound() : console.log(product);

    return product;
  } catch (e) {
    console.error(e);
  }
})(+(process.argv[2] || 2));

function throwError(comboSize) {
  throw new Error(
    `Combo size of "${comboSize}" is invalid. Valid combo size values are 2 and 3.`
  );
}

function logNotFound() {
  console.log("Could not find a combination that sums to 2020");
}
