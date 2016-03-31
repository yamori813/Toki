#coding:utf-8
# http://aidiary.hatenablog.com/entry/20120415/1334458954
# http://aidiary.hatenablog.com/entry/20111102/1320241544
import sys
import aifc
import math
import numpy as np
import scipy.io.wavfile
import scipy.signal
import scipy.fftpack

def autocorr(x, nlags=None):
    """自己相関関数を求める
    x:     信号
    nlags: 自己相関関数のサイズ（lag=0からnlags-1まで）
           引数がなければ（lag=0からlen(x)-1まですべて）
    """
    N = len(x)
    if nlags == None: nlags = N
    r = np.zeros(nlags)
    for lag in range(nlags):
        for n in range(N - lag):
            r[lag] += x[n] * x[n + lag]
    return r

def LevinsonDurbin(r, lpcOrder):
    """Levinson-Durbinのアルゴリズム
    k次のLPC係数からk+1次のLPC係数を再帰的に計算して
    LPC係数を求める"""
    # LPC係数（再帰的に更新される）
    # a[0]は1で固定のためlpcOrder個の係数を得るためには+1が必要
    a = np.zeros(lpcOrder + 1)
    e = np.zeros(lpcOrder + 1)

    # k = 1の場合
    a[0] = 1.0
    a[1] = - r[1] / r[0]
    e[1] = r[0] + r[1] * a[1]
    lam = - r[1] / r[0]

    # kの場合からk+1の場合を再帰的に求める
    for k in range(1, lpcOrder):
        # lambdaを更新
        lam = 0.0
        for j in range(k + 1):
            lam -= a[j] * r[k + 1 - j]
        lam /= e[k]

        # aを更新
        # UとVからaを更新
        U = [1]
        U.extend([a[i] for i in range(1, k + 1)])
        U.append(0)

        V = [0]
        V.extend([a[i] for i in range(k, 0, -1)])
        V.append(1)

        a = np.array(U) + lam * np.array(V)

        # eを更新
        e[k + 1] = e[k] * (1.0 - lam * lam)

    return a, e[-1]


def aiffread(filename):
    af = aifc.open(filename, "r")
    fs = af.getframerate()
    x = af.readframes(af.getnframes())
    x = np.frombuffer(x, dtype="int16") / 32768.0  # (-1, 1)に正規化
    af.close()
    return x, float(fs)

def preEmphasis(signal, p):
    """プリエンファシスフィルタ"""
    # 係数 (1.0, -p) のFIRフィルタを作成
    return scipy.signal.lfilter([1.0, -p], 1, signal)

if __name__ == "__main__":
    param = sys.argv
    # 音声をロード
    src, fs = aiffread(param[1])
    nyq = fs / 2.0  # ナイキスト周波数
    fe1 = 2000.0 / nyq      # カットオフ周波数1
    fe2 = 10000.0 / nyq      # カットオフ周波数2
    numtaps = 255           # フィルタ係数（タップ）の数（要奇数）
    b = scipy.signal.firwin(numtaps, [fe1, fe2], pass_zero=False)
    wav = scipy.signal.lfilter(b, 1, src)

    t = np.arange(0.0, len(wav) / fs, 1/fs)

    # 音声波形の中心部分を切り出す
    center = len(wav) / 2  # 中心のサンプル番号
    cuttime = 0.04         # 切り出す長さ [s]
    s = wav[center - cuttime/2*fs : center + cuttime/2*fs]

    # プリエンファシスフィルタをかける
    p = 0.97         # プリエンファシス係数
    s = preEmphasis(s, p)

    # ハミング窓をかける
    hammingWindow = np.hamming(len(s))
    s = s * hammingWindow

    # LPC係数を求める
    lpcOrder = 20
    r = autocorr(s, lpcOrder + 1)
    a, e  = LevinsonDurbin(r, lpcOrder)
    print "*** result ***"
    num = 0
    while num < len(a):
      print str(num) + " " + str(a[num])
      num += 1
    print "e:", e

