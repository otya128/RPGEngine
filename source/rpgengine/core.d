module rpgengine.core;

import rpgengine.render;
import rpgengine.event;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.experimental.logger;
import core.thread;

class Engine{
  //フィールド
private:
  Renderer renderer;
  Event event;

public:
  //コンストラクタとデコンストラクタ
  this(){
    info("Load a library \"SDL2\".");
    DerelictSDL2.load;
    info("Load a library \"SDL_Image\".");
    DerelictSDL2Image.load;

    if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) logf(LogLevel.fatal,"Failed initalization of \"SDL2\".\n%s", SDL_GetError());
    info("Success initalization of \"SDL2\".");
    if(IMG_Init(IMG_INIT_PNG) != IMG_INIT_PNG) logf(LogLevel.fatal,"Failed initalization of \"SDL_Image\".\n%s", IMG_GetError());
    info("Success initalization of \"SDL_Image\"");
    return;
  }
  ~this(){
    SDL_Quit();
    IMG_Quit();
  }

  int run(string title, int width, int height){
    //初期化
    renderer = new Renderer();
    event = new Event();

    auto TrenderAndEvent = new UnderLayer(title, width, height, renderer, event);
    TrenderAndEvent.start;
    TrenderAndEvent.join;
    return 0;
  }
}

class UnderLayer : Thread {
  private bool running;

  this(string title, int width, int height, Renderer renderer, Event event){
    running = true;
    super(() => run(title, width, height, renderer, event));
  }

  void run(string title, int width, int height, Renderer renderer, Event event){
    renderer.init(title, width, height);
    event.init(renderer);
    do
    {
      renderer.render();
      event.process();
      SDL_Delay(16);
    } while(event.isRunning);
  }

  void stop(){
    running = false;
  }
}
