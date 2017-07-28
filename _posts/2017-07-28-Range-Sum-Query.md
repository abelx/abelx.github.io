---
 
 layout: post
 title: Range-Sum-Query
 subtitle: "题目来自LeetCode，对于一个数组nums，查询索引i到j之间所有数的和。实际上包括两个题目，一个是数组固定不变，另一个是数组长度固定，值可变。"
 date: 2017-07-28 
 author: abelx 
 category: 算法题解
 tags: leetcode
 finished: true 
 
--- 
## 题目
### 303. Range Sum Query - Immutable
数据元素固定不变。

> Given an integer array nums, find the sum of the elements between indices i and j (i ≤ j), inclusive.

#### 分析
给定数组nums，求解sum(i, j)。

stage1: 只存储数组，每次查询都要计算元素和。空间复杂度O(N)，时间复杂度O(N)。这样的话会超时。

stage2: 定义二维数组sums，sums[i][j] == sum(i, j)。这样的话查询的时间复杂度降维O(1)，建立二维数组sums可以通过由对角线向外快展，时间复杂度$O(N^2)$，空间复杂度也是$O(N^2)。这样的话查询复杂度降下来了，但是内存使用超限。

stage3: stage2中的数组其实只用了对角线及其上半部分，为了减少空间消耗，可以通过一位数组之存储有用的数据，然后通过一个映射函数把sums[i][j]映射到某一个位置。空间使用减少了一半，但是没有数量级上的减小，仍然内存使用超限。

stage4: 定义数组`vector<int> presum(nums.size(), 0)`，presum[i]表示从nums[0]到nums[i]之间所有数的和。空间复杂度O(N)，数组建立时间复杂度O(N)。每次查询只需要做一次减法`sum(i, j) = presum[j] - presum[i-1]`，查询时间复杂度O(1)。

end: 这种解法的启示就是累加操作可以转换成一次减法。
### 303. Range Sum Query - Mutable
数组元素可修改。

> Given an integer array nums, find the sum of the elements between indices i and j (i ≤ j), inclusive.
The update(i, val) function modifies nums by updating the element at index i to val.

#### 分析
给定数组nums，需要实现的操作有：修改update(i, val), sum(i, j)。

stage1: 沿用上个题目最优解的思想，执行update需要更新presum[i]及其后边的所有元素，时间复杂度为O(N)。查询的时间复杂度仍未O(1)，但是会超时。

stage2: stage1中的问题出在update上，看了没过的样例发现有连续的多次update情况，考虑不在update操作中更新presum数组，而在把实际更新操作放到之后的第一次查询中，这样的话多次连续update实际只需要更新一次presum数组。需要额外定义一个数组保存nums和一个标记tUpdate表示是否进行了更新。update中只做`nums[i]=val`赋值操作，然后设置tUpdate为true，时间复杂度为O(1)。sum中如果tUpdate为false直接求差，时间复杂度O(1)，否则说明之前更新过nums，需要先更新presum，然后求差，时间复杂度O(N)。仍然超时。

stage3: stage2整体上可能会缩短执行时间，但是没有从根本上降低update操作的时间复杂度。因此之前的思路本身有问题，需要一个新的思路。采用[SegmentTree线段树](http://dongxicheng.org/structure/segment-tree/)的方法，update和sum的时间复杂度都降为O(logN)，建树的时间空间复杂度都为O(NlogN)。

end: 这里用到了线段树这种新的数据结构，下文会有介绍。

## 数据结构&算法
- 线段树
- 累加操作可以转换成一次减法


### SegmentTree线段树
线段树在上文中的链接里有详细介绍，他的适用场景有如下要求：

1. 在数组中进行范围查询query(i, j)
2. 定长数组，数组长度不可变
3. 最好有数组元素的更新操作

用于实现上述范围求和问题的线段树的实现如下，要改造成求最大最小值的线段树只需要改一下\_build和\_update方法中的相应逻辑就可以了。

```
struct SegmentTreeNode {
    int valL;
    int valR;
    int sum;
    SegmentTreeNode *pL;
    SegmentTreeNode *pR;
    SegmentTreeNode(int l, int r) : valL(l), valR(r), pL(NULL), pR(NULL) {}
};

class SegmentTree {
public:
    SegmentTree(vector<int> &nums){
        pTree = NULL;
        if(nums.size() == 0) return;
        pTree = _build(nums, 0, nums.size()-1);
        iSize = nums.size();
    }
    
    ~SegmentTree(){
        if(pTree) _delete(pTree);
    }
    
    int get(int l, int r){
        if(l < 0 || r >= iSize || r < l) return 0;
        //cout << pTree->sum << endl;
        return _get(pTree, l ,r);
    }
    
    int update(int i, int val){
        if(i < 0 || i >= iSize) return 0;
        return _update(pTree, i, val);
    }   

private:
    SegmentTreeNode *_build(vector<int> &nums, int l, int r){
        SegmentTreeNode *p = new SegmentTreeNode(l, r);
        if( l == r) {
            p->sum = nums[l];
            return p;
        }
        int mid = (l + r) / 2;
        p->pL = _build(nums, l, mid);
        p->pR = _build(nums, mid+1, r);
        p->sum = p->pL->sum + p->pR->sum;
        return p;  
    }
    
    void _delete(SegmentTreeNode *p){
        if(p->pL) _delete(p->pL);
        if(p->pR) _delete(p->pR);
        delete p;
    }
    
    int _get(SegmentTreeNode *p, int l, int r){
        if(l == p->valL && r == p->valR) return p->sum;
        int mid = (p->valL + p->valR) / 2;
        if(r <= mid) return _get(p->pL, l, r);
        if(l > mid) return _get(p->pR, l, r);
        return _get(p->pL, l, mid) + _get(p->pR, mid+1, r);
    }
    
    int _update(SegmentTreeNode *p, int i, int val){
        int diff = 0;
        if(p->valL == p->valR) {
            diff = val - p->sum;
            p->sum = val;
            return diff;
        }
        int mid = (p->valL + p->valR) / 2;
        if(i <= mid) diff = _update(p->pL, i, val);
        if(i > mid) diff = _update(p->pR, i, val);
        p->sum += diff;
        return diff;
    }
    
    SegmentTreeNode *pTree;
    int iSize;
};
```