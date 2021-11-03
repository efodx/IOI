PShape sloveniaShape; //<>// //<>// //<>// //<>//
float shapeWidth = 4000;
float shapeHeight = shapeWidth*210/297;

String NASLOV = "Vpliv višine povprečne plače na dnevne migracije (po regijah 2020)";

int povprecnaPlaca = 1252;
int maxPovprecnaPlaca = 0;
int minPovprecnaPlaca = 1999900;

float minProcentMigrantov = 923043984;
float maxProcentMigrantov = 0;


float maxDelezMigrantov = 0;
float minDelezMigrantov = 1999900;

int currentlyDrawing = -1;
float interpolator = 0;

String[] regije = {"pomurska", "podravska", "koroška", "savinjska", "zasavska", "posavska",
  "jugovzhodna-slovenija", "osrednjeslovenska", "gorenjska", "primorsko-notranjska", "goriška", "obalno-kraška"};

String[] imenaRegij = {"Pomurska", "Podravska", "Koroška", "Savinjska", "Zasavska", "Posavska",
  "Jugovzhodna Slovenija", "Osrednjeslovenska", "Gorenjska", "Primorsko-notranjska", "Goriška", "Obalno-kraška"};

int[] barveRegij = {-5591836, -6640445, -4608134, -8499590, -2279963, -4835099,
  -1069851, -5878194, -4388352, -5898240, -4388240, -4337296};

int[][] lokacijeRegij = {{978, 152}, {828, 249}, {610, 210}, {663, 355}, {563, 429}, {741, 508},
  {581, 631}, {417, 473}, {288, 337}, {332, 636}, {163, 458}, {219, 672}};

Regija[] regions = new Regija[12];

PShape[] regionShapes = new PShape[12];

PGraphics areaChecker;
Table tabelaRegij;


class Regija {
  String id;
  int povprecnaPlaca;
  HashMap<String, Integer> delavciPoRegijah;
  int delavciSkupaj = 0;
  int delavciIzvenRegije = 0;

  Regija(String id, int povprecnaPlaca, HashMap<String, Integer> delavciPoRegijah) {
    this.id = id;
    this.povprecnaPlaca = povprecnaPlaca;
    this.delavciPoRegijah = delavciPoRegijah;

    for (var entry : delavciPoRegijah.entrySet()) {
      this.delavciSkupaj += entry.getValue();
      if (!entry.getKey().equals(this.id)) {
        this.delavciIzvenRegije += entry.getValue();
      }
    }
  }
}


void loadOffscreenDrawnRegions() {
  areaChecker.beginDraw();

  for (int i = 0; i<12; i++) {
    String regija =  regije[i];
    PShape shapeRegije = sloveniaShape.getChild(regija);
    regionShapes[i] = shapeRegije;
  }

  for (PShape regija : regionShapes) {
    areaChecker.shape(regija, 0, 0, shapeWidth, shapeHeight);
  }

  areaChecker.endDraw();
}

void loadPodatki() {
  tabelaRegij = new Table("clean-podatki.tsv");
  for (int row=0; row < tabelaRegij.getRowCount(); row++) {
    String id = tabelaRegij.getRowName(row);
    id = imenaRegij[row]; // ne prebere pravilno sumnikov iz tabele :&, zato hekamo tu

    int povprecnaPlacaVRegiji = tabelaRegij.getInt(row, 1);

    if (povprecnaPlacaVRegiji < minPovprecnaPlaca) {
      minPovprecnaPlaca = povprecnaPlacaVRegiji;
    }
    if (povprecnaPlacaVRegiji > maxPovprecnaPlaca) {
      maxPovprecnaPlaca = povprecnaPlacaVRegiji;
    }

    int pomurska = tabelaRegij.getInt(row, 2);
    int podravska = tabelaRegij.getInt(row, 3);
    int koroska = tabelaRegij.getInt(row, 4);
    int savinjska = tabelaRegij.getInt(row, 5);
    int zasavska = tabelaRegij.getInt(row, 6);
    int posavska = tabelaRegij.getInt(row, 7);
    int jugovzhodna = tabelaRegij.getInt(row, 8);
    int osrednjeslovenska = tabelaRegij.getInt(row, 9);
    int gorenjska = tabelaRegij.getInt(row, 10);
    int primorskoNotranjska = tabelaRegij.getInt(row, 11);
    int goriska = tabelaRegij.getInt(row, 12);
    int obalnoKraska = tabelaRegij.getInt(row, 13);

    HashMap<String, Integer> delavciPoRegijah = new HashMap<String, Integer>();
    delavciPoRegijah.put("Pomurska", pomurska);
    delavciPoRegijah.put("Podravska", podravska);
    delavciPoRegijah.put("Koroška", koroska);
    delavciPoRegijah.put("Savinjska", savinjska);
    delavciPoRegijah.put("Zasavska", zasavska);
    delavciPoRegijah.put("Posavska", posavska);
    delavciPoRegijah.put("Jugovzhodna Slovenija", jugovzhodna);
    delavciPoRegijah.put("Osrednjeslovenska", osrednjeslovenska);
    delavciPoRegijah.put("Gorenjska", gorenjska);
    delavciPoRegijah.put("Primorsko-notranjska", primorskoNotranjska);
    delavciPoRegijah.put("Goriška", goriska);
    delavciPoRegijah.put("Obalno-kraška", obalnoKraska);

    regions[row] = new Regija(id, povprecnaPlacaVRegiji, delavciPoRegijah);

    if ((float) regions[row].delavciIzvenRegije/regions[row].delavciSkupaj < minProcentMigrantov) {
      minProcentMigrantov = (float) regions[row].delavciIzvenRegije/regions[row].delavciSkupaj;
    }
    if ((float) regions[row].delavciIzvenRegije/regions[row].delavciSkupaj > maxProcentMigrantov) {
      maxProcentMigrantov = (float) regions[row].delavciIzvenRegije/regions[row].delavciSkupaj;
    }
  }
}


void drawLinesForRegion(int region) {
  if (currentlyDrawing != region) {
    interpolator = 0;
    currentlyDrawing = region;
  } else {
    interpolator = min(interpolator+0.1, 1);
  }
  for (int i = 0; i < 12; i++) {
    if (i != region) {
      int delavciVRegiji =  regions[region].delavciPoRegijah.get(imenaRegij[i]);
      float procentDelavcev = ((float) delavciVRegiji)*100/regions[region].delavciSkupaj;
      strokeWeight(procentDelavcev);
      line(lokacijeRegij[region][0], lokacijeRegij[region][1], (1-sqrt(interpolator))*lokacijeRegij[region][0] +  sqrt(interpolator)*lokacijeRegij[i][0], (1-sqrt(interpolator))*lokacijeRegij[region][1] +  sqrt(interpolator)*lokacijeRegij[i][1]);
    }
  }
  strokeWeight(1);
}

void displayInfoAboutSelectedRegion(int selectedRegion) {

  stroke(0, 0, 0, 255*sqrt(interpolator));
  fill(0, 0, 100, 255*sqrt(interpolator));
  rect(880, 420, 570, 350);
  
  textSize(50);
  String imeRegije = regije[selectedRegion];
  imeRegije = imeRegije.substring(0, 1).toUpperCase() + imeRegije.substring(1);
  
  fill(0, 0, 0, 255*sqrt(interpolator));

  textAlign(CENTER);
  text(imeRegije, 880+570/2, 435+50);


  Regija regija = regions[selectedRegion];

  var sortedRegije = new ArrayList<String>();

  for (var entry : regija.delavciPoRegijah.entrySet()) {
    var added = false;
    for (int i = 0; i < sortedRegije.size(); i++) {
      String ime = sortedRegije.get(i);
      if (regija.delavciPoRegijah.get(ime) < entry.getValue()) {
        sortedRegije.add(i, entry.getKey());
        added = true;
        break;
      }
    }
    if (!added) {
      sortedRegije.add(entry.getKey());
    }
  }

  textSize(30);
  for (int i=1; i< 6; i++) {
    String targetRegion = sortedRegije.get(i);
    float procentMigrantov = ((float) round((float) regija.delavciPoRegijah.get(targetRegion)/regija.delavciSkupaj * 1000))/10;
    textAlign(LEFT);
    text(targetRegion, 902+5, 435+50 + i*50);
    text("  " + procentMigrantov +  "%", 902+5+320, 435+50 + i*50);
    strokeWeight(procentMigrantov);
    line(902+450, 435+50 - 10 + i*50, 902+500, 435+50 - 10 + i*50);
  }
  stroke(0, 0, 0, 255);
}


void setup() {
  size(1500, 800);
  colorMode(HSB, 360, 100, 100);

  sloveniaShape = loadShape("slo_regije.svg");
  areaChecker = createGraphics(1500, 800);

  loadOffscreenDrawnRegions();
  loadPodatki();
}


Integer findSelectedRegion() {
  Integer selectedRegion = null;
  for (int i = 0; i < 12; i++) {
    if (areaChecker.get(mouseX, mouseY) == barveRegij[i]) {
      selectedRegion = i;
      break;
    }
  }
  return selectedRegion;
}

void draw() {
  background(255);
  Integer selectedRegion = findSelectedRegion();

  drawNaslov();

  drawRegije();
  drawDeleziMigrantov();

  if (selectedRegion != null) {
    displayInfoAboutSelectedRegion(selectedRegion);
    drawLinesForRegion(selectedRegion);
    drawDelezMigrantovForRegion(selectedRegion); // To keep it on top
  } else {
    interpolator = 0;
    currentlyDrawing = -1;
  }

  drawLegend();
}

void drawNaslov() {
  fill(0, 0, 100);
  textSize(30);
  textAlign(LEFT);
  text(NASLOV, 40, 40);
}

void drawRegije() {
  stroke(0, 0, 0);
  for (int i = 0; i < 12; i++) {
    PShape regija = regionShapes[i];
    regija.disableStyle();

    float howMuchColor = map(regions[i].povprecnaPlaca, minPovprecnaPlaca, maxPovprecnaPlaca, 20, 100);

    fill(218, howMuchColor, 100);
    shape(regija, 0, 0, shapeWidth, shapeHeight);
  }
}


void drawLegend() {
  rect(1220, 50, 200, 150);

  textSize(25);
  fill(0, 0, 0);
  textAlign(CENTER);
  text("Povprečna plača", 1320, 80);

  for (int i = 20; i<=100; i++) {
    stroke(218, i, 100);
    line(1220+10+10, 65+10+5+i, 1220+10+10+40, 65+10+5+i);
  }

  textSize(20);
  stroke(218, 20, 100);
  line(1220+10+40, 65+10+5+20, 1220+10+100, 65+10+5+20);
  
  
  stroke(0,0,0,100);
  textAlign(CENTER,CENTER);
  text(minPovprecnaPlaca+ "€", 1215+150, 65+15+20);

  line(1220+10+40, 65+10+80+5+20, 1220+10+100, 65+10+80+5+20);
  
  
  stroke(218, 100, 100);
  textAlign(CENTER,CENTER);
  text(maxPovprecnaPlaca+ "€", 1215+150, 65+10+80+20);

  fill(0, 0, 100);
  stroke(0, 0, 0);
  rect(1220, 210, 200, 150);

  textSize(25);
  fill(0, 0, 0);
  textAlign(CENTER);
  text("Dnevni migrantje", 1320, 80+160);

  fill(0, 0, 100);
  ellipse(1253, 260, 60*0.08, 60*0.08);

  fill(0, 0, 0);
  textAlign(CENTER, CENTER);
  stroke(0,0,0,100);
  line(1253, 260, 1320, 260);
  
  textSize(20);
  text((float) round(1000*minProcentMigrantov)/10 + "%", 1253+100, 258);

  fill(0, 0, 100, 80);

  stroke(0, 0, 0, 100);
  ellipse(1253, 260+8, 60* 0.15, 60*0.15);
  ellipse(1253, 260+22, 60* 0.3, 60*0.3);
  ellipse(1253, 260+43, 60* 0.40, 60*0.40);


  stroke(0, 0, 0);
  ellipse(1253, 330, 60*0.5, 60*0.5);
  
  stroke(0,0,0,100);
  line(1253, 330, 1320, 330);
  fill(0, 0, 0);
  textSize(20);
  text((float) round(1000*maxProcentMigrantov)/10 + "%", 1253+100, 328);
}

void drawDeleziMigrantov() {
  for (int i = 0; i < 12; i++) {
    drawDelezMigrantovForRegion(i);
  }
}

void drawDelezMigrantovForRegion(int i) {
  fill(0, 0, 100);
  float delezMigrantov = (float) regions[i].delavciIzvenRegije/regions[i].delavciSkupaj;
  ellipse(lokacijeRegij[i][0], lokacijeRegij[i][1], 60*delezMigrantov, 60*delezMigrantov);
}

void mousePressed() {
  // int i = findSelectedRegion();
  // print((float) regions[i].delavciIzvenRegije/regions[i].delavciSkupaj + "\n");
  print(mouseX + ","+ mouseY+"\n");
}
