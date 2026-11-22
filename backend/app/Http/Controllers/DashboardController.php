<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Expense;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    /**
     * Get dashboard summary data for authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $now = Carbon::now();

        $month = $request->input('month', $now->month);
        $year = $request->input('year', $now->year);

        // 1. Base Query for the selected month and year
        $monthlyQuery = Expense::where('user_id', $user->id)
            ->whereMonth('date', $month)
            ->whereYear('date', $year);

        $totalExpense = (float) $monthlyQuery->sum('amount');

        // 2. Category Breakdown / Summary
        $categories = Category::all();
        $categoriesSummary = [];

        foreach ($categories as $category) {
            $catTotal = (float) Expense::where('user_id', $user->id)
                ->where('category_id', $category->id)
                ->whereMonth('date', $month)
                ->whereYear('date', $year)
                ->sum('amount');

            $percentage = $totalExpense > 0 ? round(($catTotal / $totalExpense) * 100, 1) : 0;

            $categoriesSummary[] = [
                'category_id' => $category->id,
                'name' => $category->name,
                'icon' => $category->icon,
                'color' => $category->color,
                'total_amount' => $catTotal,
                'percentage' => $percentage,
            ];
        }

        // 3. Recent 5 Transactions
        $recentTransactions = Expense::with('category')
            ->where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->orderBy('id', 'desc')
            ->limit(5)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                'filter' => [
                    'month' => (int) $month,
                    'year' => (int) $year,
                ],
                'total_expense' => $totalExpense,
                'categories_summary' => $categoriesSummary,
                'recent_transactions' => $recentTransactions,
            ],
        ]);
    }
}
