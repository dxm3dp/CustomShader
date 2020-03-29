# 空间变换

2020.3.29(7)

在渲染流水线中 , 我们往往需要把一个点或方向矢量从一个坐标空间转换到另一个坐标空间 . 这个过程到底是怎么实现的呢 ?

我们知道 , 要想定义一个坐标空间 , 必须指明其原点位置和 3 个坐标轴的方向 . 而这些数值实际上是相对于另一个坐标空间的 ( 所有的都是相对的 ) . 也就是说 , 坐标空间会形成一个层次结构 -- 每个坐标空间都是另一个坐标空间的子空间 , 反过来说 , 每个空间都有一个父坐标空间 . **对坐标空间的变换实际上就是在父空间和子空间之间对点和矢量进行变换** .

假设 , 现在有父坐标空间 P 以及一个子坐标空间 C . 我们知道在父坐标空间中子坐标空间的原点位置以及 3 个单位坐标轴 . 我们一般会有两种需求 : 一种需求是把子坐标空间下表示的点或矢量 $A_c$ 转换到父坐标空间下的表示 $A_p$ , 另一个需求是反过来 , 把父坐标空间下表示的点或矢量 $B_p$ 转换到子坐标空间下的表示 $B_c$ . 我们可以使用下面的公式来表示这两种需求 :

$$
A_p = M_{c\rightarrow p} A_c
$$

$$
B_c = M_{p\rightarrow c} B_p
$$

其中 , $M_{c\rightarrow p}$ 表示的是从子坐标空间变换到父坐标空间的变换矩阵 , 而 $M_{p\rightarrow c}$ 是其逆矩阵 ( 即反向变换 ) . 那么 , 现在的问题就是 , 如何求解这些变换矩阵 ? 事实上 , 我们只需要解出两者之一即可 , 另一个矩阵可以通过求逆矩阵的方式来得到 .

下面 , 我们就来讲解如何求出从子坐标空间到父坐标空间的变换矩阵 $M_{c\rightarrow p}$ .

首先 , 我们来回顾一个看似很简单的问题 : 当给定一个坐标空间以及其中一点 ( a , b , c ) 时 , 我们是如何知道该点的位置的呢 ? 我们可以通过 4 个步骤来确定它的位置 :

1. 从坐标空间的原点开始 ;
2. 向 x 轴方向移动 a 个单位 ;
3. 向 y 轴方向移动 b 个单位 ;
4. 向 z 轴方向移动 c 个单位 .

需要说明的是 , 上面的步骤只是我们的想象 , 这个点并没有发生移动 . 上面的步骤看起来再简单不过了 , 坐标空间的变换就蕴含在上面的 4 个步骤中 .

现在 , 我们已知子坐标空间 $C$ 的 3 个坐标轴在父坐标空间 $P$ 下的表示 $x_c$ , $y_c$ , $z_c$ , 以及其原点位置 $O_c$ . 当给定一个子坐标空间中的一点 $A_c = (a, b, c)$ , 我们同样可以依照上面 4 个步骤来确定其在父坐标空间下的位置 $A_p$ :

**从坐标空间的原点开始** . 这很简单 , 我们已经知道了子坐标空间的原点位置 $O_c$ .

**向 x 轴方向移动 a 个单位** . 仍然很简单 , 因为我们已经知道了 x 轴的矢量表示 , 因此可以得到 :

$$
O_c + ax_c
$$

**向 y 轴方向移动 b 个单位** . 同样的道理 , 这一步就是 :

$$
O_c + ax_c + by_c
$$

**向 z 轴方向移动 c 个单位** . 最后 , 就可以得到 :

$$
O_c + ax_c + by_c + cz_c
$$

现在 , 我们已经求出了 $M_{c\rightarrow p}$ ! 我们再来看一下最后得到的式子 :

$$
A_p = O_c + ax_c + by_c + cz_c
$$

你可能会问 , 这个式子里根本没有矩阵呀 ! 真的是这样吗 ?

$$
\begin{aligned}
A_p &= O_c + ax_c + by_c + cz_c \\
    &= (x_{o_c} , y_{o_c} , z_{o_c}) + a(x_{x_c} , y_{x_c} , z_{x_c}) + b(x_{y_c} , y_{y_c} , z_{y_c}) + c(x_{z_c} , y_{z_c} , z_{z_c}) \\
    &= (x_{o_c} , y_{o_c} , z_{o_c}) +
    \left[ \begin{matrix}
        x_{x_c} & x_{y_c} & x_{z_c} \\
        y_{x_c} & y_{y_c} & y_{z_c} \\
        z_{x_c} & z_{y_c} & z_{z_c}
        \end{matrix}
    \right]
    \left[ \begin{matrix}
        a \\
        b \\
        c
    \end{matrix}
    \right] \\
    &= (x_{o_c} , y_{o_c} , z_{o_c}) +
    \left[ \begin{matrix}
        | & | & | \\
        x_c & y_c & z_c \\
        | & | & |
        \end{matrix}
    \right]
    \left[ \begin{matrix}
        a \\
        b \\
        c
    \end{matrix}
    \right]
\end{aligned}
$$

其中 "|" 符号表示是按列展开的 . 这个最后的表达式还不是很漂亮 , 因为还存在加法表达式 , 即平移变换 . 我们已经知道 , $3 \times 3$ 的矩阵无法表示平移变换 , 因此为了得到一个更漂亮的结果 , 我们把上面的式子扩展到齐次坐标空间中 , 得

$$
\begin{aligned}
A_p &= (x_{o_c} , y_{o_c} , z_{o_c} , 1) +
    \left[
        \begin{matrix}
        | & | & | & 0 \\
        x_c & y_c & z_c & 0 \\
        | & | & | & 0 \\
        0 & 0 & 0 & 1
        \end{matrix}
    \right]
    \left[
        \begin{matrix}
        a \\
        b \\
        c \\
        1
        \end{matrix}
    \right] \\
    &=
    \left[
        \begin{matrix}
        1 & 0 & 0 & x_{o_c} \\
        0 & 1 & 0 & y_{o_c} \\
        0 & 0 & 1 & z_{o_c} \\
        0 & 0 & 0 & 1
        \end{matrix}
    \right]
    \left[
        \begin{matrix}
        | & | & | & 0 \\
        x_c & y_c & z_c & 0 \\
        | & | & | & 0 \\
        0 & 0 & 0 & 1
        \end{matrix}
    \right]
    \left[
        \begin{matrix}
        a \\
        b \\
        c \\
        1
        \end{matrix}
    \right] \\
    &=
    \left[
        \begin{matrix}
        | & | & | & x_{o_c} \\
        x_c & y_c & z_c & y_{o_c} \\
        | & | & | & z_{o_c} \\
        0 & 0 & 0 & 1
        \end{matrix}
    \right]
    \left[
        \begin{matrix}
        a \\
        b \\
        c \\
        1
        \end{matrix}
    \right] \\
    &=
    \left[
        \begin{matrix}
        | & | & | & | \\
        x_c & y_c & z_c & o_c \\
        | & | & | & | \\
        0 & 0 & 0 & 1
        \end{matrix}
    \right]
    \left[
        \begin{matrix}
        a \\
        b \\
        c \\
        1
        \end{matrix}
    \right] \\

\end{aligned}
$$

现在 , 发现 $M_{c \rightarrow p}$ 在哪里了吧 . 没错 ,
