function [result, SeparatingAxis, MaxDepth] = Intersection_BoxToBox(ABox, BBox)
% Intersection_BoxToBox 判断两个旋转盒子（OBB）是否相交
% 输入：
%   ABox, BBox - 结构体，包含字段：
%       FCenter: 1x3 向量
%       FExtent: 1x3 向量（半长）
%       FAxis:   3x3 矩阵，每一行为一个局部坐标轴（单位向量）
% 输出：
%   result - 布尔值，true 表示相交，false 表示不相交
%   SeparatingAxis - 字符串，记录产生最小穿透的分离轴（如 'S_AXIS_A0' 等）
%   MaxDepth - 最小穿透深度（或经过交叉轴测试时经过归一化的值）

    % 初始化
    result = false;
    SeparatingAxis = 'S_AXIS_NONE';
    MaxDepth = inf;
    EPSILON = 1e-6;

    % 计算两盒子中心的相对距离
    D = BBox.FCenter - ABox.FCenter;  % 1x3 向量

    % 取出各盒子的半长
    a0 = ABox.FExtent(1); a1 = ABox.FExtent(2); a2 = ABox.FExtent(3);
    b0 = BBox.FExtent(1); b1 = BBox.FExtent(2); b2 = BBox.FExtent(3);

    % 取出局部坐标轴（假设每行为一个轴）
    A0 = ABox.FAxis(1,:);
    A1 = ABox.FAxis(2,:);
    A2 = ABox.FAxis(3,:);
    B0 = BBox.FAxis(1,:);
    B1 = BBox.FAxis(2,:);
    B2 = BBox.FAxis(3,:);

    %% 测试 6 个盒子局部坐标轴

    % 1. 以 ABox 的第一个轴 A0 为分离轴
    A0D = dot(A0, D);
    c00 = dot(A0, B0);
    c01 = dot(A0, B1);
    c02 = dot(A0, B2);
    R = abs(A0D);
    R0 = a0;
    R1 = b0*abs(c00) + b1*abs(c01) + b2*abs(c02);
    TmpDepth = R0 + R1 - R;
    if TmpDepth < 0
        return;  % 不相交
    end
    if MaxDepth > TmpDepth
        MaxDepth = TmpDepth;
        SeparatingAxis = 'S_AXIS_A0';
    end

    % 2. 以 ABox 的第二个轴 A1 为分离轴
    A1D = dot(A1, D);
    c10 = dot(A1, B0);
    c11 = dot(A1, B1);
    c12 = dot(A1, B2);
    R = abs(A1D);
    R0 = a1;
    R1 = b0*abs(c10) + b1*abs(c11) + b2*abs(c12);
    TmpDepth = R0 + R1 - R;
    if TmpDepth < 0
        return;
    end
    if MaxDepth > TmpDepth
        MaxDepth = TmpDepth;
        SeparatingAxis = 'S_AXIS_A1';
    end

    % 3. 以 ABox 的第三个轴 A2 为分离轴
    A2D = dot(A2, D);
    c20 = dot(A2, B0);
    c21 = dot(A2, B1);
    c22 = dot(A2, B2);
    R = abs(A2D);
    R0 = a2;
    R1 = b0*abs(c20) + b1*abs(c21) + b2*abs(c22);
    TmpDepth = R0 + R1 - R;
    if TmpDepth < 0
        return;
    end
    if MaxDepth > TmpDepth
        MaxDepth = TmpDepth;
        SeparatingAxis = 'S_AXIS_A2';
    end

    % 4. 以 BBox 的第一个轴 B0 为分离轴
    B0D = dot(B0, D);
    R = abs(B0D);
    R0 = a0*abs(c00) + a1*abs(c01) + a2*abs(c02);
    R1 = b0;
    TmpDepth = R0 + R1 - R;
    if TmpDepth < 0
        return;
    end
    if MaxDepth > TmpDepth
        MaxDepth = TmpDepth;
        SeparatingAxis = 'S_AXIS_B0';
    end

    % 5. 以 BBox 的第二个轴 B1 为分离轴
    B1D = dot(B1, D);
    R = abs(B1D);
    R0 = a0*abs(c10) + a1*abs(c11) + a2*abs(c12);
    R1 = b1;
    TmpDepth = R0 + R1 - R;
    if TmpDepth < 0
        return;
    end
    if MaxDepth > TmpDepth
        MaxDepth = TmpDepth;
        SeparatingAxis = 'S_AXIS_B1';
    end

    % 6. 以 BBox 的第三个轴 B2 为分离轴
    B2D = dot(B2, D);
    R = abs(B2D);
    R0 = a0*abs(c20) + a1*abs(c21) + a2*abs(c22);
    R1 = b2;
    TmpDepth = R0 + R1 - R;
    if TmpDepth < 0
        return;
    end
    if MaxDepth > TmpDepth
        MaxDepth = TmpDepth;
        SeparatingAxis = 'S_AXIS_B2';
    end

    %% 测试交叉轴
    % 定义内部辅助函数：测试交叉轴
    function test_sep_axis(axisName, DirA, DirB, relativeVal, R0_val, R1_val)
        TempAxis = cross(DirA, DirB);
        AxisLen = dot(TempAxis, TempAxis); % 计算平方长度
        if AxisLen > EPSILON
            R_val = relativeVal;
            TmpDepth_local = R0_val + R1_val - abs(R_val);
            if TmpDepth_local < 0
                error('No intersection on cross axis %s', axisName);
            end
            if (MaxDepth * AxisLen > TmpDepth_local)
                MaxDepth = TmpDepth_local / AxisLen;
                SeparatingAxis = axisName;
            end
        end
    end

    % 注意：以下各测试中，各项的 relativeVal、R0 和 R1 均根据 C++ 代码给出的表达式计算
    try
        % 7. S_AXIS_A0B0
        test_sep_axis('S_AXIS_A0B0', A0, B0, c10 * A2D - c20 * A1D, a1 * abs(c20) + a2 * abs(c10), b1 * abs(c02) + b2 * abs(c01));
        % 8. S_AXIS_A0B1
        test_sep_axis('S_AXIS_A0B1', A0, B1, c11 * A2D - c21 * A1D, a1 * abs(c21) + a2 * abs(c11), b0 * abs(c02) + b2 * abs(c00));
        % 9. S_AXIS_A0B2
        test_sep_axis('S_AXIS_A0B2', A0, B2, c12 * A2D - c22 * A1D, a1 * abs(c22) + a2 * abs(c12), b0 * abs(c01) + b1 * abs(c00));
        % 10. S_AXIS_A1B0
        test_sep_axis('S_AXIS_A1B0', A1, B0, c20 * A0D - c00 * A2D, a0 * abs(c20) + a2 * abs(c00), b1 * abs(c12) + b2 * abs(c11));
        % 11. S_AXIS_A1B1
        test_sep_axis('S_AXIS_A1B1', A1, B1, c21 * A0D - c01 * A2D, a0 * abs(c21) + a2 * abs(c01), b0 * abs(c12) + b2 * abs(c10));
        % 12. S_AXIS_A1B2
        test_sep_axis('S_AXIS_A1B2', A1, B2, c22 * A0D - c02 * A2D, a0 * abs(c22) + a2 * abs(c02), b0 * abs(c11) + b1 * abs(c10));
        % 13. S_AXIS_A2B0
        test_sep_axis('S_AXIS_A2B0', A2, B0, c00 * A1D - c10 * A0D, a0 * abs(c10) + a1 * abs(c00), b1 * abs(c22) + b2 * abs(c21));
        % 14. S_AXIS_A2B1
        test_sep_axis('S_AXIS_A2B1', A2, B1, c01 * A1D - c11 * A0D, a0 * abs(c11) + a1 * abs(c01), b0 * abs(c22) + b2 * abs(c20));
        % 15. S_AXIS_A2B2
        test_sep_axis('S_AXIS_A2B2', A2, B2, c02 * A1D - c12 * A0D, a0 * abs(c12) + a1 * abs(c02), b0 * abs(c21) + b1 * abs(c20));
    catch ME
        % 若任一交叉轴测试失败，则视为不相交
        result = false;
        return;
    end

    % 如果所有测试均通过，则认为盒子相交
    if strcmp(SeparatingAxis, 'S_AXIS_NONE')
        result = false;
    else
        result = true;
    end
end
