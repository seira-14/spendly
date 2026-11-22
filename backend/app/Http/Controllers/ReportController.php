<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Expense;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    /**
     * Get detailed analytics and report data for authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $now = Carbon::now();

        $month = (int) $request->input('month', $now->month);
        $year = (int) $request->input('year', $now->year);

        $selectedDate = Carbon::create($year, $month, 1);
        $daysInMonth = $selectedDate->daysInMonth;

        // Current Month Total
        $totalExpense = (float) Expense::where('user_id', $user->id)
            ->whereMonth('date', $month)
            ->whereYear('date', $year)
            ->sum('amount');

        // Previous Month Total
        $prevDate = $selectedDate->copy()->subMonth();
        $prevMonthExpense = (float) Expense::where('user_id', $user->id)
            ->whereMonth('date', $prevDate->month)
            ->whereYear('date', $prevDate->year)
            ->sum('amount');

        $percentageChange = $prevMonthExpense > 0 
            ? round((($totalExpense - $prevMonthExpense) / $prevMonthExpense) * 100, 1) 
            : 0;

        // Category Breakdown
        $categories = Category::all();
        $categoriesBreakdown = [];

        foreach ($categories as $category) {
            $catTotal = (float) Expense::where('user_id', $user->id)
                ->where('category_id', $category->id)
                ->whereMonth('date', $month)
                ->whereYear('date', $year)
                ->sum('amount');

            if ($catTotal > 0 || $totalExpense == 0) {
                $percentage = $totalExpense > 0 ? round(($catTotal / $totalExpense) * 100, 1) : 0;
                $categoriesBreakdown[] = [
                    'category_id' => $category->id,
                    'name' => $category->name,
                    'icon' => $category->icon,
                    'color' => $category->color,
                    'total_amount' => $catTotal,
                    'percentage' => $percentage,
                ];
            }
        }

        // Sort categories by total_amount descending
        usort($categoriesBreakdown, function ($a, $b) {
            return $b['total_amount'] <=> $a['total_amount'];
        });

        // Daily Breakdown for chart
        $dailyExpenses = [];
        for ($day = 1; $day <= $daysInMonth; $day++) {
            $dayDate = Carbon::create($year, $month, $day)->format('Y-m-d');
            $daySum = (float) Expense::where('user_id', $user->id)
                ->whereDate('date', $dayDate)
                ->sum('amount');

            $dailyExpenses[] = [
                'day' => $day,
                'date' => $dayDate,
                'amount' => $daySum,
            ];
        }

        // Monthly Trend (Jan - Dec for current year)
        $monthlyTrend = [];
        $monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        for ($m = 1; $m <= 12; $m++) {
            $mSum = (float) Expense::where('user_id', $user->id)
                ->whereMonth('date', $m)
                ->whereYear('date', $year)
                ->sum('amount');

            $monthlyTrend[] = [
                'month' => $m,
                'name' => $monthNames[$m - 1],
                'amount' => $mSum,
            ];
        }

        // Highest transaction
        $highestExpense = Expense::with('category')
            ->where('user_id', $user->id)
            ->whereMonth('date', $month)
            ->whereYear('date', $year)
            ->orderBy('amount', 'desc')
            ->first();

        $avgDailyExpense = $daysInMonth > 0 ? round($totalExpense / $daysInMonth) : 0;

        return response()->json([
            'status' => 'success',
            'data' => [
                'filter' => [
                    'month' => $month,
                    'year' => $year,
                ],
                'total_expense' => $totalExpense,
                'previous_month_expense' => $prevMonthExpense,
                'percentage_change' => $percentageChange,
                'average_daily_expense' => $avgDailyExpense,
                'highest_expense' => $highestExpense,
                'categories_breakdown' => $categoriesBreakdown,
                'daily_expenses' => $dailyExpenses,
                'monthly_trend' => $monthlyTrend,
            ],
        ]);
    }
}
