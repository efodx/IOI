PShape sloveniaShape; //<>// //<>// //<>//
float shapeWidth = 1200;
float shapeHeight = shapeWidth*210/297;

int povprecnaPlaca = 1252;
int maxPovprecnaPlaca = 0;
int minPovprecnaPlaca = 1999900;

String[] regije = {"pomurska", "podravska", "koroška", "savinjska", "zasavska", "posavska",
  "jugovzhodna-slovenija", "osrednjeslovenska", "gorenjska", "primorsko-notranjska", "goriška", "obalno-kraška"};

String[] imenaRegij = {"Pomurska", "Podravska", "Koroška", "Savinjska", "Zasavska", "Posavska",
  "Jugovzhodna Slovenija", "Osrednjeslovenska", "Gorenjska", "Primorsko-notranjska", "Goriška", "Obalno-kraška"};

int[] barveRegij = {-3670016, -3342336, -3014656, -2686976, -2359296, 1575026688,
  -1703936, -1048576, -589824, -1376256, -65536, -393216};

int[][] lokacijeRegij = {{1025, 135}, {863, 233}, {639, 197}, {707, 341}, {591, 432}, {768, 506}, {613, 641}, {442, 468}, {295, 326}, {348, 645}, {171, 457}, {225, 670}};

Regija[] regions = new Regija[12];

PShape[] regionShapes = new PShape[12];

PGraphics areaChecker;
Table tabelaRegij;


class Regija {
  String id;
  int povprecnaPlaca;
  HashMap<String, Integer> delavciPoRegijah;
  int delavciSkupaj;

  Regija(String id, int povprecnaPlaca, HashMap<String, Integer> delavciPoRegijah, int delavciSkupaj) {
    this.id = id;
    this.povprecnaPlaca = povprecnaPlaca;
    this.delavciPoRegijah = delavciPoRegijah;
    this.delavciSkupaj = delavciSkupaj;
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
    areaChecker.shape(regija, 0, 0, shapeWidth*3.5, shapeHeight*3.5);
  }

  areaChecker.endDraw();
}

void loadPodatki() {
  tabelaRegij = new Table("clean-podatki.tsv");
  for (int row=0; row < tabelaRegij.getRowCount(); row++) {
    String id = tabelaRegij.getRowName(row);
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
    delavciPoRegijah.put("Posavska", pomurska);
    delavciPoRegijah.put("Jugovzhodna Slovenija", jugovzhodna);
    delavciPoRegijah.put("Osrednjeslovenska", osrednjeslovenska);
    delavciPoRegijah.put("Gorenjska", gorenjska);
    delavciPoRegijah.put("Primorsko-notranjska", primorskoNotranjska);
    delavciPoRegijah.put("Goriška", goriska);
    delavciPoRegijah.put("Obalno-kraška", obalnoKraska);

    int vsota = pomurska+podravska+koroska+savinjska+zasavska+posavska+jugovzhodna+osrednjeslovenska+gorenjska+primorskoNotranjska+goriska+obalnoKraska;

    regions[row] = new Regija(id, povprecnaPlaca, delavciPoRegijah, vsota);
  }
}


void drawArrowsForSelectedRegion(int selectedRegion) {
  int vsiDelavci = 0;
  for (int i : regions[selectedRegion].delavciPoRegijah.values()) {
    vsiDelavci +=i;
  }
  for (int i = 0; i < 12; i++) {
    if (i != selectedRegion) {
      int delavciVRegiji =  regions[selectedRegion].delavciPoRegijah.get(imenaRegij[i]);
      float procentDelavcev = delavciVRegiji*100/vsiDelavci;
      strokeWeight(procentDelavcev);
      line(lokacijeRegij[selectedRegion][0], lokacijeRegij[selectedRegion][1], lokacijeRegij[i][0], lokacijeRegij[i][1]);
      strokeWeight(1);
    }
  }
}

void displayInfoAboutSelectedRegion(int selectedRegion) {
  /**
   TODO, create rectangle withj extra information on lower right.!
  **/
  int vsiDelavci = 0;
  for (int i : regions[selectedRegion].delavciPoRegijah.values()) {
    vsiDelavci +=i;
  }
  
  
  for (int i = 0; i < 12; i++) {
    if (i != selectedRegion) {
      int delavciVRegiji =  regions[selectedRegion].delavciPoRegijah.get(imenaRegij[i]);
      float procentDelavcev = delavciVRegiji*100/vsiDelavci;
      strokeWeight(procentDelavcev);
      line(lokacijeRegij[selectedRegion][0], lokacijeRegij[selectedRegion][1], lokacijeRegij[i][0], lokacijeRegij[i][1]);
      strokeWeight(1);
    }
  }
}


void setup() {
  size(1500, 800);
  sloveniaShape = loadShape("slo_regije.svg");
  areaChecker = createGraphics(1500, 800);
  loadOffscreenBuffer();
  loadPodatki();

  sloveniaShape = loadShape("slo_regije.svg");
}


void draw() {
  background(255);
  colorMode(HSB, 360, 100, 100);
  Integer selectedRegion = null;
  for (int i = 0; i < 12; i++) {
    PShape regija = regionShapes[i];
    regija.disableStyle();

    float howMuchColor = map(regions[i].povprecnaPlaca, minPovprecnaPlaca, maxPovprecnaPlaca, 20, 100);

    if (areaChecker.get(mouseX, mouseY) == barveRegij[i]) {
      selectedRegion = i;
      fill(218, howMuchColor-20, 100);
    } else {
      fill(218, howMuchColor, 100);
    }
    shape(regija, 0, 0, shapeWidth*3.5, shapeHeight*3.5);
  }
  if (selectedRegion != null) {
    displayInfoAboutSelectedRegion(selectedRegion);
    drawArrowsForSelectedRegion(selectedRegion);
    ellipse(lokacijeRegij[selectedRegion][0], lokacijeRegij[selectedRegion][1], 30, 30);
  }





  //if (selectedRegion != null) {
  //  fill(255, 255, 255);
  //  rect(mouseX, mouseY-150, 300, 150);
  //  textSize(30);

  //  fill(0, 0, 612);

  //  String imeRegije = regije[selectedRegion];
  //  imeRegije = imeRegije.substring(0, 1).toUpperCase() + imeRegije.substring(1);
  //  text(imeRegije, mouseX+5, mouseY-150+30);
  //}
}

void mousePressed() {
  print(mouseX + "," + mouseY+ "\n");
}


class Tuple {
  private String imeRegije;
  private float procentIzhodov;
}
