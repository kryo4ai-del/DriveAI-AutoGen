const fs = require('fs');
const path = require('path');
const config = require('../config');

function scanFactoryHealth() {
  const components = [];

  // Read .env for API key checks (only check existence, never expose values)
  const envPath = path.join(config.FACTORY_BASE, '.env');
  let envContent = '';
  if (fs.existsSync(envPath)) {
    envContent = fs.readFileSync(envPath, 'utf-8');
  }

  const hasKey = (name) => {
    const regex = new RegExp(`^${name}=.+`, 'm');
    return regex.test(envContent);
  };

  const hasAnthropicKey = hasKey('ANTHROPIC_API_KEY');
  const hasOpenAIKey = hasKey('OPENAI_API_KEY');
  const hasGoogleKey = hasKey('GOOGLE_AI_API_KEY') || hasKey('GEMINI_API_KEY');
  const hasMistralKey = hasKey('MISTRAL_API_KEY');
  const hasSerpApiKey = hasKey('SERPAPI_API_KEY');
  const providerCount = [hasAnthropicKey, hasOpenAIKey, hasGoogleKey, hasMistralKey].filter(Boolean).length;

  // 1. TheBrain / Model Provider
  const brainRegistry = path.join(config.PATHS.brain, 'models_registry.json');
  const brainExists = fs.existsSync(brainRegistry);
  let modelCount = 0;
  if (brainExists) {
    try {
      const registry = JSON.parse(fs.readFileSync(brainRegistry, 'utf-8'));
      modelCount = Array.isArray(registry) ? registry.length : Object.keys(registry).length;
    } catch (e) { /* parse error */ }
  }

  components.push({
    name: 'TheBrain',
    icon: 'Brain',
    status: brainExists && providerCount >= 2 ? 'green' : brainExists ? 'yellow' : 'red',
    message: brainExists
      ? `${modelCount} Modelle, ${providerCount}/4 Provider konfiguriert`
      : 'models_registry.json nicht gefunden',
    details: {
      registry: brainExists ? 'OK' : 'Fehlt',
      models: modelCount,
      anthropic: hasAnthropicKey ? 'OK' : 'Fehlt',
      openai: hasOpenAIKey ? 'OK' : 'Fehlt',
      google: hasGoogleKey ? 'OK' : 'Fehlt',
      mistral: hasMistralKey ? 'OK' : 'Fehlt',
    }
  });

  // 2. SerpAPI
  components.push({
    name: 'SerpAPI',
    icon: 'Search',
    status: hasSerpApiKey ? 'green' : 'red',
    message: hasSerpApiKey ? 'API-Key konfiguriert' : 'API-Key fehlt in .env',
    details: { api_key: hasSerpApiKey ? 'Konfiguriert' : 'Fehlt' }
  });

  // 3. Document Secretary
  const secDir = config.PATHS.documentSecretary;
  const secExists = fs.existsSync(secDir);
  let pdfCount = 0;
  if (secExists) {
    pdfCount = fs.readdirSync(secDir).filter(f => f.endsWith('.pdf')).length;
  }

  components.push({
    name: 'Document Secretary',
    icon: 'FileText',
    status: secExists ? 'green' : 'red',
    message: secExists ? `${pdfCount} PDFs generiert` : 'Output-Ordner nicht gefunden',
    details: { output_dir: secExists ? 'OK' : 'Fehlt', pdfs_generated: pdfCount, templates: 15 }
  });

  // 4. Memory System
  const memoryFile = path.join(config.PATHS.memory, 'learnings.md');
  const memoryExists = fs.existsSync(memoryFile);
  let memoryModified = null;
  let memorySize = 0;
  if (memoryExists) {
    const stats = fs.statSync(memoryFile);
    memoryModified = stats.mtime.toISOString().split('T')[0];
    memorySize = Math.round(stats.size / 1024);
  }

  components.push({
    name: 'Memory System',
    icon: 'Database',
    status: memoryExists ? 'green' : 'yellow',
    message: memoryExists ? `${memorySize} KB, zuletzt: ${memoryModified}` : 'learnings.md nicht gefunden',
    details: { file: memoryExists ? 'OK' : 'Fehlt', size_kb: memorySize, last_update: memoryModified }
  });

  // 5. Project Registry
  const projectsDir = config.PATHS.projects;
  const projectsExist = fs.existsSync(projectsDir);
  let projectCount = 0;
  if (projectsExist) {
    projectCount = fs.readdirSync(projectsDir).filter(d =>
      fs.existsSync(path.join(projectsDir, d, 'project.json'))
    ).length;
  }

  components.push({
    name: 'Project Registry',
    icon: 'FolderOpen',
    status: projectsExist && projectCount > 0 ? 'green' : 'yellow',
    message: `${projectCount} Projekte registriert`,
    details: { directory: projectsExist ? 'OK' : 'Fehlt', projects: projectCount }
  });

  // 6-8. Production Lines
  for (const line of ['ios', 'android', 'web']) {
    const lineLabel = line === 'ios' ? 'iOS Line' : line === 'android' ? 'Android Line' : 'Web Line';
    const possiblePaths = [
      path.join(config.FACTORY_BASE, 'factory', 'lines', line),
      path.join(config.FACTORY_BASE, 'factory', 'production', line),
      path.join(config.FACTORY_BASE, 'lines', line),
    ];
    const lineExists = possiblePaths.some(p => fs.existsSync(p));

    components.push({
      name: lineLabel,
      icon: line === 'ios' ? 'Smartphone' : line === 'android' ? 'Tablet' : 'Globe',
      status: lineExists ? 'green' : 'gray',
      message: lineExists ? 'Line verfuegbar' : 'Noch nicht eingerichtet',
      details: { available: lineExists }
    });
  }

  const statuses = components.map(c => c.status);
  const overallHealth = statuses.includes('red') ? 'red' :
                        statuses.includes('yellow') ? 'yellow' : 'green';

  return { overall: overallHealth, components, checked_at: new Date().toISOString() };
}

module.exports = { scanFactoryHealth };
