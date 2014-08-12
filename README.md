cloudforged
===========

AMHC

1. 请先在Dota2 Workhop Tools里面创建一个名为cloudforged的addon，会自动在`dota_ugc`文件夹里面生成
  ```
  dota_ugc\content\dota_addons\cloudforged
  dota_ugc\game\dota_addons\cloudforged
  ```
2.删除`dota_ugc\game\dota_addons\cloudforged`这个文件夹，将项目cloneclone到dota_ugc\game\dota_addons\文件夹

编辑器中地形，模型，贴图，粒子特效的源文件会在content文件夹生成
编译之后生成编译格式会自动在game文件夹编译成`.vpk`,`.vmat`等格式，提交生成后的格式即可

SendPullRequest之前请先确认项目是否能自动合并。
