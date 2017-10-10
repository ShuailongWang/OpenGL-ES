//
//  ViewController.m
//  01初使用OpenGL
//
//  Created by admin on 17/10/10.
//  Copyright © 2017年 wsl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *mContext;    //上下文
@property (nonatomic, strong) GLKBaseEffect *mEffect;   //着色器

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self setupUI];
    [self uploadVertexArray];
    [self uploadTexture];
}

//上下文
- (void)setupUI {
    //上下文, 分别对应着OpenGL ES 1.0，OpenGL ES 2.0，OpenGL ES 3.0
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //需要在xib中设置GLKView
    GLKView *clkView = (GLKView*)self.view;
    clkView.delegate = self;
    //设置上下文
    clkView.context = self.mContext;
    //颜色缓冲区格式
    clkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    //设置当前上下文
    [EAGLContext setCurrentContext:self.mContext];
}

//左手坐标系和右手坐标系。
//伸出左手，让拇指和食指成“L”形状，拇指向右，食指向上，中指指向起那方，这时就建立了一个“左手坐标系”，
//拇指、食指和中指分表代表x、y、z轴的正方向。
//“右手坐标系”就是用右手，
//顶点数据
- (void)uploadVertexArray{
    //顶点数据, 前面三个是顶点数据, 后面两个是文理数据
    //顶点数组里包括顶点坐标，OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
    //纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角。
    GLfloat squareVertexData[] = {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    //索引数组是顶点数组的索引，把squareVertexData数组看成4个顶点，每个顶点会有5个GLfloat数据，索引从0开始。
    //顶点数据缓存
    GLuint buffer;
    /* n: 要申请的缓冲区对象数量
     buffer: 指向n个缓冲区的数组指针，该数组存放的是缓冲区的名称
     返回的缓冲区对象名称是0以外的无符号整数，0是OpenGL ES的保留值，不表示具体的缓冲区对象，修改或者查询0的缓冲区状态产生错误
     */
    glGenBuffers(1, &buffer);
    
    /*
     target：用于指定当前的缓冲区对象的"类型"
             GL_ARRAY_BUFFER：               数组缓冲区
             GL_ELEMENT_ARRAY_BUFFER：       元素数组缓冲区
             GL_COPY_READ_BUFFER：           复制读缓冲区
             GL_COPY_WRITE_BUFFER：          复制写缓冲区
             GL_PIXEL_PACK_BUFFER：          像素包装缓冲区
             GL_PIXEL_UNPACK_BUFFER：        像素解包缓冲区
             GL_TRANSFORM_FEEDBACK_BUFFER：  变换反馈缓冲区
             GL_UNIFORM_BUFFER：             统一变量缓冲区
     buffer: 缓冲区的名称
     */
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    /* 
     target:    用于指定当前的缓冲区对象的"类型"
     size:      缓冲区数据存储大小，以字节表示
     data:      缓冲区数据的指针
     usage:     应用程序将如何使用缓冲区对象中存储的数据的提示，也就是缓冲区的使用方法，初始值为 GL_STATIC_DRAW
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    /*
     功能：用于启用通用顶点属性
     index：指定通用顶点数据的索引，这个值的范围从0到支持的最大顶点属性数量减1
     */
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    /*
     index:         通用顶点属性索引
     size:          顶点数组中为顶点属性指定的分量数量，取值范围1～4
     type:          数据格式 ，两个函数都包括的有效值是
     GL_BYTE        GL_UNSIGNED_BYTE  GL_SHORT  GL_UNSIGNED_SHORT  GL_INT  GL_UNSIGNED_INT
                    glVertexAttribPointer还包括的值为：GL_HALF_FLOAT GL_FLOAT 等
     normalized:    仅glVertexAttribPointer使用，表示非浮点数据类型转换成浮点值时是否应该规范化
     stride:        每个顶点由size指定的顶点属性分量顺序存储。stride指定顶点索引i和i+1表示的顶点之间的偏移。
                    如果为0，表示顺序存储。如果不为0，在取下一个顶点的同类数据时，需要加上偏移。
     ptr:           如果使用“顶点缓冲区对象”，表示的是该缓冲区内的偏移量。
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat*)NULL + 0);
    
    //纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat*)NULL + 3);
}


//纹理贴图
- (void)uploadTexture{
    //纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"绿叶" ofType:@"png"];
    //由于纹理坐标系是跟手机显示的Quartz 2D坐标系的y轴正好相反，纹理坐标系使用左下角为原点，往上为y轴的正值，往右是x轴的正值，所以需要设置一下GLKTextureLoaderOriginBottomLeft
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.mEffect = [[GLKBaseEffect alloc]init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}


#pragma mark - GLKViewDelegate
//渲染场景代码
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    /*
     mode: 指定要绘制的图元，我们绘制两个三角形，这里用GL_TRIANGLES
     first: 从数组缓存中的哪一位开始绘制，一般为0。
     count: 要绘制的“顶点数量”
     */
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
//    /* 
//     mode: 指定要绘制的图元，我们绘制两个三角形，这里用GL_TRIANGLES
//     count: 要绘制的“顶点数量”
//     type：指定的顶点索引的存储的值的类型
//     indices: 指向顶点索引的数组指针。
//    */
//    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}























@end
