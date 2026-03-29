const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const FACTORY_BASE = process.env.FACTORY_BASE || path.resolve(__dirname, '../../..');

module.exports = {
  FACTORY_BASE,
  PATHS: {
    projects: path.join(FACTORY_BASE, 'factory', 'projects'),
    ideas: path.join(FACTORY_BASE, 'ideas'),
    preProduction: path.join(FACTORY_BASE, 'factory', 'pre_production', 'output'),
    marketStrategy: path.join(FACTORY_BASE, 'factory', 'market_strategy', 'output'),
    mvpScope: path.join(FACTORY_BASE, 'factory', 'mvp_scope', 'output'),
    designVision: path.join(FACTORY_BASE, 'factory', 'design_vision', 'output'),
    visualAudit: path.join(FACTORY_BASE, 'factory', 'visual_audit', 'output'),
    roadbookAssembly: path.join(FACTORY_BASE, 'factory', 'roadbook_assembly', 'output'),
    documentSecretary: path.join(FACTORY_BASE, 'factory', 'document_secretary', 'output'),
    brain: path.join(FACTORY_BASE, 'factory', 'brain', 'model_provider'),
    memory: path.join(FACTORY_BASE, 'factory', 'pre_production', 'memory'),
    storePrep: path.join(FACTORY_BASE, 'factory', 'store_prep', 'output'),
    assetForge: path.join(FACTORY_BASE, 'factory', 'asset_forge', 'output'),
    soundForge: path.join(FACTORY_BASE, 'factory', 'sound_forge'),
    sceneForge: path.join(FACTORY_BASE, 'factory', 'scene_forge'),
    motionForge: path.join(FACTORY_BASE, 'factory', 'motion_forge'),
    integration: path.join(FACTORY_BASE, 'factory', 'integration'),
    qaForge: path.join(FACTORY_BASE, 'factory', 'qa_forge', 'reports'),
    marketing: path.join(FACTORY_BASE, 'factory', 'marketing'),
    dispatcher: path.join(FACTORY_BASE, 'factory', 'dispatcher'),
    capabilities: path.join(FACTORY_BASE, 'factory', 'hq', 'capabilities', 'reports'),
  },
  SCAN_INTERVAL: 15000,
  PORT: process.env.DASHBOARD_PORT || 3001,
};
