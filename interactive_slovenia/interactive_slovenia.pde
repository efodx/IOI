PShape sloveniaShape; //<>// //<>// //<>// //<>//
float shapeWidth = 4000;
float shapeHeight = shapeWidth*210/297;

String NASLOV = "Vpliv višine povprečne plače na dnevne migracije (po regijah 2020)";

int povprecnaPlaca = 1252;
int maxPovprecnaPlaca = 0;
int minPovprecnaPlaca = 1999900;

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


void loadOffscreenBuffer() {
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
    id = imenaRegij[row]; // ne prebere pravilno sumnikov iz tabele :&



    print(id + "\n");
    int povprecnaPlaca = tabelaRegij.getInt(row, 1);

    if (povprecnaPlaca < minPovprecnaPlaca) {
      minPovprecnaPlaca = povprecnaPlaca;
    }
    if (povprecnaPlaca > maxPovprecnaPlaca) {
      maxPovprecnaPlaca = povprecnaPlaca;
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

    regions[row] = new Regija(id, povprecnaPlaca, delavciPoRegijah);
  }
}


void drawArrowsForSelectedRegion(int selectedRegion) {

  if (currentlyDrawing != selectedRegion) {
    interpolator = 0;
    currentlyDrawing = selectedRegion;
  } else {
    interpolator = min(interpolator+0.1, 1);
  }
  for (int i = 0; i < 12; i++) {
    if (i != selectedRegion) {
      int delavciVRegiji =  regions[selectedRegion].delavciPoRegijah.get(imenaRegij[i]);
      float procentDelavcev = ((float) delavciVRegiji)*100/regions[selectedRegion].delavciSkupaj;
      strokeWeight(procentDelavcev);
      line(lokacijeRegij[selectedRegion][0], lokacijeRegij[selectedRegion][1], (1-sqrt(interpolator))*lokacijeRegij[selectedRegion][0] +  sqrt(interpolator)*lokacijeRegij[i][0], (1-sqrt(interpolator))*lokacijeRegij[selectedRegion][1] +  sqrt(interpolator)*lokacijeRegij[i][1]);
      float k = (lokacijeRegij[selectedRegion][0] -   lokacijeRegij[i][0])/ (lokacijeRegij[i][1] - lokacijeRegij[selectedRegion][1]);

      //pushMatrix();
      //translate(lokacijeRegij[i][0], lokacijeRegij[i][1]);
      //if(lokacijeRegij[selectedRegion][0] -   lokacijeRegij[i][0]>0){
      //rotate(atan(k)+PI);

      //}else{
      //rotate(atan(k));

      //}
      //triangle(-30, 30, 0, -30, 30, 30);
      //popMatrix();


      strokeWeight(1);
    }
  }
}

void displayInfoAboutSelectedRegion(int selectedRegion) {

  stroke(0, 0, 0, 255*sqrt(interpolator));

  fill(0, 0, 100, 255*sqrt(interpolator));
  rect(880, 420, 570, 350);
  textSize(50);
  String imeRegije = regije[selectedRegion];
  imeRegije = imeRegije.substring(0, 1).toUpperCase() + imeRegije.substring(1);
  //text(imeRegije, mouseX+5, mouseY-150+30);
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
  stroke(0,0,0,255);
}


void setup() {
  size(1500, 800);
  sloveniaShape = loadShape("slo_regije.svg");
  areaChecker = createGraphics(1500, 800);
  loadOffscreenBuffer();
  loadPodatki();

  sloveniaShape = loadShape("slo_regije.svg");
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
  colorMode(HSB, 360, 100, 100);
  Integer selectedRegion = findSelectedRegion();
  textSize(30);
  text(NASLOV, 40, 40);
  for (int i = 0; i < 12; i++) {
    PShape regija = regionShapes[i];
    regija.disableStyle();

    float howMuchColor = map(regions[i].povprecnaPlaca, minPovprecnaPlaca, maxPovprecnaPlaca, 20, 100);


    //if (areaChecker.get(mouseX, mouseY) == barveRegij[i]) {
    //  selectedRegion = i;
    //  if(currentlyDrawing != selectedRegion){
    //    interpolator = 0;
    //    currentlyDrawing = selectedRegion;
    //  }else{
    //    interpolator = min(interpolator+0.1, 1);
    //  }
    //  fill(218, howMuchColor-20, 100);
    //} else {
    fill(218, howMuchColor, 100);
    //}
    shape(regija, 0, 0, shapeWidth, shapeHeight);

    fill(218, 0, 100);
  }
  drawDelezMigrantov();
  if (selectedRegion != null) {
    displayInfoAboutSelectedRegion(selectedRegion);
    drawArrowsForSelectedRegion(selectedRegion);
    drawDelezMigrantovForRegion(selectedRegion);
  } else {
    interpolator = 0;
    currentlyDrawing = -1;
  }
}

void drawDelezMigrantov() {
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
}
