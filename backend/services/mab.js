const { Sequelize, DataTypes } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

let sequelize;

// Initialize Sequelize connection with auto-fallback to SQLite in memory
const initSequelize = async () => {
  try {
    sequelize = new Sequelize(
      process.env.MYSQL_DATABASE || 'vynedam_db',
      process.env.MYSQL_USER || 'vynedam_user',
      process.env.MYSQL_PASSWORD || 'vynedam_password',
      {
        host: process.env.MYSQL_HOST || 'localhost',
        port: parseInt(process.env.MYSQL_PORT || '3306'),
        dialect: 'mysql',
        logging: false,
        pool: {
          max: 5,
          min: 0,
          acquire: 30000,
          idle: 10000
        }
      }
    );
    await sequelize.authenticate();
    console.log('MySQL connected successfully via Sequelize.');
  } catch (error) {
    console.warn('MySQL connection failed. Falling back to SQLite in-memory database for local testing.');
    sequelize = new Sequelize('sqlite::memory:', { logging: false });
  }

  // Define MAB Option model
  const MABOption = sequelize.define('MABOption', {
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    views: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    rewards: {
      type: DataTypes.DOUBLE,
      defaultValue: 0.0
    },
    successRate: {
      type: DataTypes.VIRTUAL,
      get() {
        const v = this.getDataValue('views');
        const r = this.getDataValue('rewards');
        return v > 0 ? r / v : 0.0;
      }
    }
  });

  await sequelize.sync();

  // Seed default options if empty
  const count = await MABOption.count();
  if (count === 0) {
    await MABOption.bulkCreate([
      { name: 'Red Sign-Up Button', views: 0, rewards: 0 },
      { name: 'Blue Sign-Up Button', views: 0, rewards: 0 },
      { name: 'Green Sign-Up Button', views: 0, rewards: 0 },
    ]);
    console.log('Seeded default MAB options (MySQL/SQLite).');
  }

  return MABOption;
};

let MABOption;

const getMABModel = async () => {
  if (!MABOption) {
    MABOption = await initSequelize();
  }
  return MABOption;
};

/**
 * Epsilon-Greedy Recommendation Selection
 * @param {number} epsilon probability of choosing exploration (0.0 to 1.0)
 */
async function getRecommendation(epsilon = 0.2) {
  const model = await getMABModel();
  const options = await model.findAll();

  if (options.length === 0) {
    throw new Error('No MAB options seeded in database.');
  }

  let selectedOption;

  // Epsilon-Greedy Logic
  if (Math.random() < epsilon) {
    // EXPLORE: Choose random option
    const randomIndex = Math.floor(Math.random() * options.length);
    selectedOption = options[randomIndex];
    console.log(`[MAB] EXPLORE -> Selected: ${selectedOption.name}`);
  } else {
    // EXPLOIT: Choose option with the highest success rate
    let bestOption = options[0];
    let bestRate = bestOption.successRate;

    for (let i = 1; i < options.length; i++) {
      const rate = options[i].successRate;
      if (rate > bestRate) {
        bestRate = rate;
        bestOption = options[i];
      }
    }
    selectedOption = bestOption;
    console.log(`[MAB] EXPLOIT -> Selected: ${selectedOption.name} (Success Rate: ${selectedOption.successRate.toFixed(4)})`);
  }

  // Increment views in database
  selectedOption.views += 1;
  await selectedOption.save();

  return selectedOption;
}

/**
 * Tracks User Interaction and updates reward value in database
 * @param {number} id Option database ID
 * @param {string} interactionType 'positive' (+1), 'negative' (-1), or 'completed' (+5)
 */
async function recordInteraction(id, interactionType) {
  const model = await getMABModel();
  const option = await model.findByPk(id);

  if (!option) {
    throw new Error(`MAB Option with ID ${id} not found.`);
  }

  let reward = 0;
  if (interactionType === 'positive') {
    reward = 1;
  } else if (interactionType === 'negative') {
    reward = -1;
  } else if (interactionType === 'completed') {
    reward = 5;
  }

  option.rewards += reward;
  await option.save();

  console.log(`[MAB] Updated option: ${option.name}. Views: ${option.views}, Rewards: ${option.rewards}, Success Rate: ${option.successRate.toFixed(4)}`);
  return option;
}

async function getAllOptions() {
  const model = await getMABModel();
  return await model.findAll();
}

module.exports = {
  getRecommendation,
  recordInteraction,
  getAllOptions
};
