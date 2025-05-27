import pytest
import sys
import os

if __name__ == '__main__':
    # 保证当前路径在 PYTHONPATH 中
    sys.path.insert(0, os.path.abspath('.'))

    # pytest 参数
    args = [
        '--cov=verl',                      # 要统计覆盖率的包
        '--cov-report=xml:coverage.xml',  # 输出 coverage.xml
        'tests/bp/'                        # 测试目录
    ]

    # 执行 pytest
    sys.exit(pytest.main(args))
