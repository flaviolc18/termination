#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/raw_ostream.h"
#include <iostream>
#include <vector>

using namespace llvm;
using namespace std;

namespace
{
unsigned countNestedLoops(Loop *L, unsigned level)
{
	unsigned maxLevel = level;
	vector<Loop *> subLoops = L->getSubLoops();

	for (auto loop : subLoops)
		maxLevel = max(maxLevel, countNestedLoops(loop, level + 1));

	return maxLevel;
}

struct NestedLoopCounter : public ModulePass
{
	static char ID;
	NestedLoopCounter() : ModulePass(ID) {}

	void getAnalysisUsage(AnalysisUsage &analysisUsage) const override
	{
		analysisUsage.addRequired<LoopInfoWrapperPass>();
		analysisUsage.setPreservesAll();
	}

	bool runOnModule(Module &module) override
	{
		unsigned maxNestedLoops = 0;

		for (auto &func : module)
		{
			if (!func.isDeclaration())
			{
				LoopInfo &loopInfo = getAnalysis<LoopInfoWrapperPass>(func).getLoopInfo();
				for (auto loop : loopInfo)
					maxNestedLoops = max(maxNestedLoops, countNestedLoops(loop, 1));
			}
		}

		cout << maxNestedLoops << "\n";

		return false;
	}
};
} // namespace

char NestedLoopCounter::ID = 0;
static RegisterPass<NestedLoopCounter> X("nested-loop-counter", "Count the number of nested loops in the program");