<?php

namespace App\Http\Controllers;

use App\Models\Expense;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    /**
     * Display a listing of expenses for authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $query = Expense::with('category')->where('user_id', $userId);

        if ($request->filled('month')) {
            $query->whereMonth('date', $request->month);
        }

        if ($request->filled('year')) {
            $query->whereYear('date', $request->year);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('notes', 'like', "%{$search}%");
            });
        }

        $expenses = $query->orderBy('date', 'desc')
                          ->orderBy('id', 'desc')
                          ->get();

        $totalAmount = $expenses->sum('amount');

        return response()->json([
            'status' => 'success',
            'data' => [
                'total_amount' => $totalAmount,
                'count' => $expenses->count(),
                'expenses' => $expenses,
            ],
        ]);
    }

    /**
     * Store a newly created expense in database.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric|min:1',
            'date' => 'required|date',
            'notes' => 'nullable|string',
        ]);

        $expense = $request->user()->expenses()->create($validated);
        $expense->load('category');

        return response()->json([
            'status' => 'success',
            'message' => 'Pengeluaran berhasil ditambahkan!',
            'data' => [
                'expense' => $expense,
            ],
        ], 201);
    }

    /**
     * Display the specified expense.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $expense = Expense::with('category')
            ->where('user_id', $request->user()->id)
            ->find($id);

        if (!$expense) {
            return response()->json([
                'status' => 'error',
                'message' => 'Pengeluaran tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'expense' => $expense,
            ],
        ]);
    }

    /**
     * Update the specified expense in database.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $expense = Expense::where('user_id', $request->user()->id)->find($id);

        if (!$expense) {
            return response()->json([
                'status' => 'error',
                'message' => 'Pengeluaran tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'category_id' => 'sometimes|required|exists:categories,id',
            'title' => 'sometimes|required|string|max:255',
            'amount' => 'sometimes|required|numeric|min:1',
            'date' => 'sometimes|required|date',
            'notes' => 'nullable|string',
        ]);

        $expense->update($validated);
        $expense->load('category');

        return response()->json([
            'status' => 'success',
            'message' => 'Pengeluaran berhasil diperbarui!',
            'data' => [
                'expense' => $expense,
            ],
        ]);
    }

    /**
     * Remove the specified expense from database.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $expense = Expense::where('user_id', $request->user()->id)->find($id);

        if (!$expense) {
            return response()->json([
                'status' => 'error',
                'message' => 'Pengeluaran tidak ditemukan.',
            ], 404);
        }

        $expense->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Pengeluaran berhasil dihapus!',
        ]);
    }
}
