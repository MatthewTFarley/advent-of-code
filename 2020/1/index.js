(function main(comboSizes) {
  try {
    const nums = extractNumsFromInputFile();
    const product = getProduct(comboSizes, nums);
    Number.isNaN(product) ? logNotFound() : console.log(product);

    return product;
  } catch (e) {
    console.log(e);
  }
})(+(process.argv[2] || 2));

function extractNumsFromInputFile() {
  return require("fs")
    .readFileSync(require("path").join(__dirname, "input.txt"))
    .toString()
    .split("\n")
    .map((line) => +line);
}

function buildLookup(comboSizes, nums) {
  return comboSizes == 2
    ? nums.reduce(
        (acc, num) => ({
          ...acc,
          [num]: 2020 - num,
        }),
        {}
      )
    : nums.reduce(
        (acc, num) => ({
          ...acc,
          [num]: nums.reduce(
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

function getProduct(comboSizes, nums) {
  let addend1,
    addend2,
    addend3 = 1;

  const lookup = buildLookup(comboSizes, nums);

  switch (comboSizes) {
    case 2:
      addend1 = nums.find((num) => lookup[2020 - num]);
      addend2 = lookup[addend1];
      break;
    case 3:
      nums.forEach((num) =>
        nums.forEach((num2) => {
          if (lookup[num] && lookup[num][2020 - num - num2]) {
            if (num * num2 * (2020 - num - num2) > 0) {
              addend1 = num;
              addend2 = num2;
              addend3 = 2020 - num - num2;
            }
          }
        })
      );
  }
  return addend1 * addend2 * addend3;
}

function logNotFound() {
  console.log("Could not find a combination that sums to 2020");
}
