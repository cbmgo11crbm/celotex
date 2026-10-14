import React, { useMemo } from 'react';
import ReactECharts from 'echarts-for-react';

function getTextColor() {
  if (typeof window === 'undefined' || typeof document === 'undefined') {
    return '#111827';
  }
  return document.documentElement.classList.contains('dark') ? '#f3f4f6' : '#111827';
}

export default function EChartBase({ option, height = 220, className = '' }) {
  const textColor = getTextColor();

  const finalOption = useMemo(() => {
    const defaults = {
      backgroundColor: 'transparent',
      textStyle: { color: textColor },
      title: { textStyle: { color: textColor } },
      legend: { textStyle: { color: textColor } },
      tooltip: { textStyle: { color: textColor } },
      xAxis: {
        axisLine: { lineStyle: { color: textColor } },
        axisLabel: { color: textColor },
        splitLine: { lineStyle: { color: textColor, opacity: 0.1 } },
      },
      yAxis: {
        axisLine: { lineStyle: { color: textColor } },
        axisLabel: { color: textColor },
        splitLine: { lineStyle: { color: textColor, opacity: 0.1 } },
      },
    };
    return {
      ...defaults,
      ...option,
      xAxis: option.xAxis ? { ...defaults.xAxis, ...option.xAxis } : undefined,
      yAxis: option.yAxis ? { ...defaults.yAxis, ...option.yAxis } : undefined,
    };
  }, [option, textColor]);

  return (
    <div className={className}>
      <ReactECharts
        option={finalOption}
        style={{ width: '100%', height }}
        notMerge={true}
        lazyUpdate={true}
      />
    </div>
  );
}
