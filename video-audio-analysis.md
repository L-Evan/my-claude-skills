# Video Audio Analysis Skill

## 概述
本技能用于从视频文件中提取音频，进行语音识别转录，并生成结构化分析报告。适用于教学视频、会议记录、培训内容等多媒体材料的智能分析和总结。

## 功能特点
- 🎥 视频音频提取（支持多种格式）
- 🎤 中文语音识别转录（Whisper AI）
- 📊 内容结构化分析
- 📝 自动生成分析报告
- ⏱️ 带时间戳的分段转录

## 工具依赖
### 必需工具
1. **FFmpeg** - 音视频处理
   ```bash
   # macOS
   brew install ffmpeg

   # Ubuntu/Debian
   sudo apt-get install ffmpeg
   ```

2. **Whisper** - 语音识别
   ```bash
   pip3 install openai-whisper
   ```

3. **Python 3.9+** - 脚本运行环境

## 使用场景
- 📚 在线课程内容整理
- 🎓 培训视频知识提取
- 💼 会议记录生成
- 📖 教程文档编写
- 🔍 媒体内容分析

## 操作流程

### 步骤1: 准备视频文件
1. 将视频文件放置在项目目录中
2. 确保视频格式支持（MP4, AVI, MOV等）

### 步骤2: 音频提取
```bash
# 提取音频并转换为WAV格式
ffmpeg -i "视频文件路径.mp4" -vn -acodec pcm_s16le -ar 16000 -ac 1 "输出音频.wav"

# 参数说明：
# -vn: 不处理视频
# -acodec pcm_s16le: 使用PCM 16位编码
# -ar 16000: 采样率16kHz
# -ac 1: 单声道
```

### 步骤3: 语音识别转录
```python
import whisper

# 加载模型（base模型速度快，medium准确度高）
model = whisper.load_model('base')  # 或 'medium'

# 转录音频
result = model.transcribe('音频文件.wav', language='zh')

# 获取转录文本
full_text = result['text']

# 获取分段内容（带时间戳）
segments = result['segments']
for segment in segments:
    start = segment['start']
    end = segment['end']
    text = segment['text'].strip()
    print(f'[{start:.2f} - {end:.2f}] {text}')
```

### 步骤4: 内容分析
根据转录内容进行结构化分析：
1. 提取关键概念和主题
2. 识别重要步骤和流程
3. 整理工具和资源清单
4. 生成实战建议

### 步骤5: 生成报告
创建markdown格式的分析报告，包含：
- 📄 视频信息（标题、时长、内容类型）
- 🎯 核心内容摘要
- 📋 详细步骤解析
- 💡 实战建议
- 🔗 相关资源链接

## 实际案例

### 案例：SEO培训视频分析
**视频**: 5.7 SEO优化策略 Web.Cafe
**时长**: 17分47秒
**结果**: 生成完整的SEO实战指南

#### 处理步骤
```bash
# 1. 音频提取
ffmpeg -i "/path/to/video.mp4" -vn -acodec pcm_s16le -ar 16000 -ac 1 "/tmp/seo_audio.wav"

# 2. 语音识别
python3 -c "
import whisper
model = whisper.load_model('base')
result = model.transcribe('/tmp/seo_audio.wav', language='zh')
print(result['text'])
" > /tmp/transcript.txt

# 3. 分析并生成报告
# 根据转录内容创建结构化分析报告
```

#### 生成的报告结构
```markdown
# SEO视频分析报告

## 视频信息
- 标题: SEO实战教程
- 时长: 17分47秒
- 内容类型: 实战操作指南

## 核心内容
### SEO优化的6个步骤
1. 关键词研究
2. 确定目标关键词
3. 页面内容优化
4. 技术SEO优化
5. 分析工具配置
6. 外链建设
7. 效果监测

## 详细解析
[每个步骤的详细说明和工具清单]
```

## 优化技巧

### 模型选择
- **base模型**: 速度快，文件小（约139MB），适合快速处理
- **medium模型**: 准确度高，文件大（约1.42GB），适合精确分析
- **large模型**: 最高准确度，文件超大（约3GB），适合专业用途

### 音频质量优化
```bash
# 降噪处理
ffmpeg -i input.mp4 -af "highpass=f=80,lowpass=f=8000" output.wav

# 音量标准化
ffmpeg -i input.wav -filter:a "volume=1.5" output.wav
```

### 并行处理
```python
# 处理多个视频文件
import os
import glob

video_files = glob.glob('videos/*.mp4')
for video_file in video_files:
    # 提取音频
    # 语音识别
    # 生成报告
```

## 输出文件说明

### 转录文件
- **完整转录**: `/tmp/transcript_base.txt`
- **分段内容**: 包含时间戳的逐句转录
- **文件大小**: 约50-70KB（取决于视频长度）

### 分析报告
- **格式**: Markdown (.md)
- **位置**: 项目 `docs/` 目录
- **命名**: `视频分析报告_[主题].md`

## 常见问题

### Q: 转录准确率不高怎么办？
A: 尝试以下方法：
1. 使用medium或large模型
2. 预处理音频（降噪、标准化）
3. 手动校正关键部分
4. 使用专业音频编辑软件

### Q: 处理速度太慢？
A: 优化方案：
1. 使用base模型
2. 缩短音频片段
3. 使用GPU加速（需要安装CUDA版本的PyTorch）
4. 并行处理多个文件

### Q: 中文识别效果差？
A: 检查要点：
1. 确保使用 `language='zh'` 参数
2. 音频质量要好（清晰、无背景噪音）
3. 说话者发音要清晰
4. 可以尝试手动标注一些专有名词

## 扩展应用

### 1. 自动生成学习笔记
```python
def generate_notes(transcript):
    # 提取要点
    # 生成思维导图
    # 创建学习计划
    pass
```

### 2. 内容问答系统
```python
def create_qa(transcript):
    # 生成问答对
    # 提取FAQ
    # 创建测验题
    pass
```

### 3. 多语言支持
```python
# 支持多种语言识别
languages = ['zh', 'en', 'ja', 'ko']
for lang in languages:
    result = model.transcribe('audio.wav', language=lang)
```

## 参考资源

### Whisper官方
- [OpenAI Whisper](https://github.com/openai/whisper)
- [模型下载](https://huggingface.co/openai/whisper-medium)

### FFmpeg资源
- [FFmpeg官网](https://ffmpeg.org/)
- [命令行参考](https://ffmpeg.org/ffmpeg.html)

### 相关工具
- [AudioMass](https://audiomass.co/) - 在线音频处理
- [Audacity](https://www.audacityteam.org/) - 免费音频编辑器
- [Descript](https://www.descript.com/) - 专业音频编辑

---

**创建日期**: 2025-11-01
**版本**: v1.0
**维护者**: Claude Code Assistant
**适用场景**: 多媒体内容分析、知识提取、内容创作
