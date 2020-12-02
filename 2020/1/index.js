(function main(comboSize) {
  const COMBO_SIZE_TO_PRODUCT_FN_MAP = new Map();
  COMBO_SIZE_TO_PRODUCT_FN_MAP.set(2, getProductsComboSizeTwo);
  COMBO_SIZE_TO_PRODUCT_FN_MAP.set(3, getProductsComboSizeThree);

  try {
    const nums = extractInput();
    const getProduct = COMBO_SIZE_TO_PRODUCT_FN_MAP.get(comboSize);
    !getProduct && throwError(comboSize);
    const product = getProduct(nums);
    Number.isNaN(product) ? logNotFound() : console.log(product);

    return product;
  } catch (e) {
    console.error(e);
  }
})(+(process.argv[2] || 2));

function extractInput() {
  return require("fs")
    .readFileSync(require("path").join(__dirname, "input.txt"))
    .toString()
    .split("\n")
    .map((line) => +line);
}

function buildLookupComboSizeTwo(nums) {
  return nums.reduce(
    (acc, num) => ({
      ...acc,
      [num]: 2020 - num,
    }),
    {}
  );
}

function buildLookupComboSizeThree(nums) {
  return nums.reduce(
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

function getProductsComboSizeTwo(nums) {
  const lookup = buildLookupComboSizeTwo(nums);
  const addend1 = nums.find((num) => lookup[2020 - num]);
  const addend2 = lookup[addend1];
  return addend1 * addend2;
}

function getProductsComboSizeThree(nums) {
  let addend1;
  let addend2;
  let addend3;
  const lookup = buildLookupComboSizeThree(nums);

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

  return addend1 * addend2 * addend3;
}

function throwError(comboSize) {
  throw new Error(
    `Combo size of "${comboSize}" is invalid. Valid combo size values are 2 and 3.`
  );
}

function logNotFound() {
  console.log("Could not find a combination that sums to 2020");
}
