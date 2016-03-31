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
    """������شؿ������
    x:     ����
    nlags: ������شؿ��Υ�������lag=0����nlags-1�ޤǡ�
           �������ʤ���С�lag=0����len(x)-1�ޤǤ��٤ơ�
    """
    N = len(x)
    if nlags == None: nlags = N
    r = np.zeros(nlags)
    for lag in range(nlags):
        for n in range(N - lag):
            r[lag] += x[n] * x[n + lag]
    return r

def LevinsonDurbin(r, lpcOrder):
    """Levinson-Durbin�Υ��르�ꥺ��
    k����LPC��������k+1����LPC������Ƶ�Ū�˷׻�����
    LPC���������"""
    # LPC�����ʺƵ�Ū�˹���������
    # a[0]��1�Ǹ���Τ���lpcOrder�Ĥη��������뤿��ˤ�+1��ɬ��
    a = np.zeros(lpcOrder + 1)
    e = np.zeros(lpcOrder + 1)

    # k = 1�ξ��
    a[0] = 1.0
    a[1] = - r[1] / r[0]
    e[1] = r[0] + r[1] * a[1]
    lam = - r[1] / r[0]

    # k�ξ�礫��k+1�ξ���Ƶ�Ū�˵���
    for k in range(1, lpcOrder):
        # lambda�򹹿�
        lam = 0.0
        for j in range(k + 1):
            lam -= a[j] * r[k + 1 - j]
        lam /= e[k]

        # a�򹹿�
        # U��V����a�򹹿�
        U = [1]
        U.extend([a[i] for i in range(1, k + 1)])
        U.append(0)

        V = [0]
        V.extend([a[i] for i in range(k, 0, -1)])
        V.append(1)

        a = np.array(U) + lam * np.array(V)

        # e�򹹿�
        e[k + 1] = e[k] * (1.0 - lam * lam)

    return a, e[-1]


def aiffread(filename):
    af = aifc.open(filename, "r")
    fs = af.getframerate()
    x = af.readframes(af.getnframes())
    x = np.frombuffer(x, dtype="int16") / 32768.0  # (-1, 1)��������
    af.close()
    return x, float(fs)

def preEmphasis(signal, p):
    """�ץꥨ��ե������ե��륿"""
    # ���� (1.0, -p) ��FIR�ե��륿�����
    return scipy.signal.lfilter([1.0, -p], 1, signal)

if __name__ == "__main__":
    param = sys.argv
    # ���������
    src, fs = aiffread(param[1])
    nyq = fs / 2.0  # �ʥ������ȼ��ȿ�
    fe1 = 2000.0 / nyq      # ���åȥ��ռ��ȿ�1
    fe2 = 10000.0 / nyq      # ���åȥ��ռ��ȿ�2
    numtaps = 255           # �ե��륿�����ʥ��åסˤο����״����
    b = scipy.signal.firwin(numtaps, [fe1, fe2], pass_zero=False)
    wav = scipy.signal.lfilter(b, 1, src)

    t = np.arange(0.0, len(wav) / fs, 1/fs)

    # �����ȷ����濴��ʬ���ڤ�Ф�
    center = len(wav) / 2  # �濴�Υ���ץ��ֹ�
    cuttime = 0.04         # �ڤ�Ф�Ĺ�� [s]
    s = wav[center - cuttime/2*fs : center + cuttime/2*fs]

    # �ץꥨ��ե������ե��륿�򤫤���
    p = 0.97         # �ץꥨ��ե���������
    s = preEmphasis(s, p)

    # �ϥߥ���򤫤���
    hammingWindow = np.hamming(len(s))
    s = s * hammingWindow

    # LPC���������
    lpcOrder = 20
    r = autocorr(s, lpcOrder + 1)
    a, e  = LevinsonDurbin(r, lpcOrder)
    print "*** result ***"
    num = 0
    while num < len(a):
      print str(num) + " " + str(a[num])
      num += 1
    print "e:", e

