package com.erp.serviceImpl;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccKindConfig;
import com.erp.model.BaseMerchant;
import com.erp.model.MerchantDiscount;
import com.erp.model.SysActionLog;
import com.erp.service.MerchantDiscountService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;

/**
 * 
 * @author Yueh
 *
 */
@Service("merchantDiscountService")
public class MerchantDiscountServiceImpl extends BaseServiceImpl implements
		MerchantDiscountService {

	@SuppressWarnings("unchecked")
	@Override
	public void addMerchantDiscount(MerchantDiscount discount) {
		try {
			// 1.参数验证, 日志
			discountNotnullValid(discount);
			SysActionLog log = saveLog();

			// 2.验证商户
			BaseMerchant merchant = (BaseMerchant) findOnlyRowByHql("from BaseMerchant where merchantId = '"
					+ discount.getMerchantId() + "'");
			if (merchant == null) {
				throw new CommonException("商户不存在.");
			} else if (!merchant.getMerchantState().equals(Constants.STATE_ZC)) {
				throw new CommonException("商户状态不正常.");
			}

			// 3.验证账户类型
			AccKindConfig accKind = (AccKindConfig) publicDao.get(
					AccKindConfig.class, discount.getAccKind());
			if (accKind == null) {
				throw new CommonException("账户类型不存在.");
			} else if (!accKind.getAccKindState().equals(Constants.STATE_ZC)) {
				throw new CommonException("账户类型状态不正常.");
			}

			// 4.验证商户，账户类型
			String sql = "select 1 from pay_merchant_acctype where merchant_id = '"
					+ discount.getMerchantId()
					+ "' and acc_kind = '"
					+ discount.getAccKind() + "'";
			Object object = findOnlyFieldBySql(sql);
			if (object == null) {
				throw new CommonException("商户[" + merchant.getMerchantName()
						+ "]不能消费账户类型[" + accKind.getAccName() + "].");
			}

			// 5.保存
			discount.setInsertDate(log.getDealTime());
			discount.setState(MerchantDiscount.STATE_UNCHECKED);
			discount.setInsertUserId(log.getUserId());

			publicDao.save(discount);

			log.setMessage("新增商户折扣率[编号:" + discount.getId() + "]");
		} catch (CommonException e) {
			throw new CommonException("新增商户折扣率失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("新增商户折扣率失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	@SuppressWarnings({ "unchecked" })
	@Override
	public void modifyMerchantDiscount(MerchantDiscount discount) {
		try {
			// 1.参数验证, 日志
			if (discount == null || discount.getId() == null) {
				throw new CommonException("折扣率为空.");
			} else if (discount.getStartDate() == null) {
				throw new CommonException("折扣率生效时间为空.");
			}

			discountTypeValid(discount);

			SysActionLog log = saveLog();

			// 2.验证折扣率
			MerchantDiscount discount2 = (MerchantDiscount) publicDao.get(
					MerchantDiscount.class, discount.getId());

			if (discount2 == null) {
				throw new CommonException("折扣率不存在.");
			} else if (!discount2.getState().equals(
					MerchantDiscount.STATE_UNCHECKED)) {
				throw new CommonException("折扣率状态不是[待审核], 不能修改.");
			}

			// 3.验证商户
			BaseMerchant merchant = (BaseMerchant) findOnlyRowByHql("from BaseMerchant where merchantId = '"
					+ discount2.getMerchantId() + "'");
			if (merchant == null) {
				throw new CommonException("商户不存在.");
			} else if (!merchant.getMerchantState().equals(Constants.STATE_ZC)) {
				throw new CommonException("商户状态不正常.");
			}

			// 4.验证账户类型
			AccKindConfig accKind = (AccKindConfig) publicDao.get(
					AccKindConfig.class, discount.getAccKind());
			if (accKind == null) {
				throw new CommonException("账户类型不存在.");
			} else if (!accKind.getAccKindState().equals(Constants.STATE_ZC)) {
				throw new CommonException("账户类型状态不正常.");
			}

			// 5.验证商户，账户类型
			String sql = "select 1 from pay_merchant_acctype where merchant_id = '"
					+ discount2.getMerchantId()
					+ "' and acc_kind = '"
					+ discount2.getAccKind() + "'";
			Object object = findOnlyFieldBySql(sql);
			if (object == null) {
				throw new CommonException("商户[" + merchant.getMerchantName()
						+ "]不能消费账户类型[" + accKind.getAccName() + "].");
			}

			// 6.保存
			discount2.setAccKind(accKind.getAccKind());
			discount2.setDiscountType(discount.getDiscountType());
			discount2.setDiscountText(discount.getDiscountText());
			discount2.setDiscount(discount.getDiscount());
			discount2.setStartDate(discount.getStartDate());
			discount2.setNote(discount.getNote());

			log.setMessage("修改商户折扣率[编号:" + discount.getId() + "]");
		} catch (CommonException e) {
			throw new CommonException("修改商户折扣率失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("修改商户折扣率失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCheckMerchantDiscount(MerchantDiscount discount) {
		try {
			// 1.参数验证, 日志
			if (discount == null || discount.getId() == null) {
				throw new CommonException("折扣率为空.");
			}

			SysActionLog log = saveLog();

			// 2.验证折扣率
			MerchantDiscount discount2 = (MerchantDiscount) publicDao.get(
					MerchantDiscount.class, discount.getId());

			if (discount2 == null) {
				throw new CommonException("折扣率不存在.");
			} else if (!discount2.getState().equals(
					MerchantDiscount.STATE_UNCHECKED)) {
				throw new CommonException("折扣率状态不是[待审核], 不能审核.");
			}

			// 3.保存
			discount2.setState(MerchantDiscount.STATE_CHECKED);

			log.setMessage("审核商户折扣率[编号:" + discount.getId() + "]");
		} catch (CommonException e) {
			throw new CommonException("审核商户折扣率失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("审核商户折扣率失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCancelMerchantDiscount(MerchantDiscount discount) {
		try {
			// 1.参数验证, 日志
			if (discount == null || discount.getId() == null) {
				throw new CommonException("折扣率为空.");
			}

			SysActionLog log = saveLog();

			// 2.验证折扣率
			MerchantDiscount discount2 = (MerchantDiscount) publicDao.get(
					MerchantDiscount.class, discount.getId());

			if (discount2 == null) {
				throw new CommonException("折扣率不存在.");
			} else if (discount2.getState().equals(
					MerchantDiscount.STATE_CANCEL)) {
				throw new CommonException("折扣率状态[已注销], 不能注销.");
			}

			// 3.保存
			discount2.setState(MerchantDiscount.STATE_CANCEL);

			log.setMessage("注销商户折扣率[编号:" + discount.getId() + "]");
		} catch (CommonException e) {
			throw new CommonException("注销商户折扣率失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("注销商户折扣率失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	private void discountNotnullValid(MerchantDiscount discount) {
		if (discount == null) {
			throw new CommonException("折扣率为空.");
		} else if (discount.getMerchantId() == null) {
			throw new CommonException("商户为空.");
		} else if (discount.getAccKind() == null) {
			throw new CommonException("账户类型为空.");
		} else if (discount.getDiscountType() == null) {
			throw new CommonException("折扣方式为空.");
		} else if (!discount.getDiscountType().equals("1")
				&& !discount.getDiscountType().equals("2")
				&& !discount.getDiscountType().equals("3")) {
			throw new CommonException("折扣方式不正确.");
		} else if (discount.getDiscountText() == null) {
			throw new CommonException("折扣时间为空.");
		} else if (discount.getDiscount() == null) {
			throw new CommonException("折扣率为空.");
		} else if (discount.getStartDate() == null) {
			throw new CommonException("生效日期为空.");
		}

		// 折扣方式, 时间段验证
		discountTypeValid(discount);
	}

	private void discountTypeValid(MerchantDiscount discount) {
		if (discount.getDiscountType().equals("1")) {
			// String reg =
			// "[1-9]|[1-2][0-9]|3[0-1](\\|[1-9]|[1-2][0-9]|3[0-1]){0,30}";
			//
			// if (!discount.getDiscountText().matches(reg)) {
			// throw new CommonException("折扣时间不正确.");
			// }

			validDiscountPeriodRepeat(discount);
		} else if (discount.getDiscountType().equals("2")) {
			// String reg = "[1-7](\\|[1-7]){0,6}";
			//
			// if (!discount.getDiscountText().matches(reg)) {
			// throw new CommonException("折扣时间不正确.");
			// }

			validDiscountPeriodRepeat(discount);
		} else if (discount.getDiscountType().equals("3")) {
			if (!DateUtil.checkDate(discount.getDiscountText())) {
				throw new CommonException("折扣时间不正确.");
			}
		} else {
			throw new CommonException("折扣时间不正确.");
		}

		// 折扣率验证
		if (discount.getDiscount() > 100 || discount.getDiscount() <= 0) {
			throw new CommonException("折扣率不正确.");
		}
	}

	private void validDiscountPeriodRepeat(MerchantDiscount discount) {
		String[] periods = discount.getDiscountText().split("\\|");

		if (periods.length == 0) {
			throw new CommonException("折扣时间为空.");
		}

		for (int i = 0; i < periods.length; i++) {
			for (int j = 0; j < periods.length; j++) {
				if (j == i)
					continue;
				if (periods[i].equals(periods[j])) {
					throw new CommonException("折扣时间段不能重复, 第[" + (i + 1)
							+ "]个与第[" + (j + 1) + "]个时间段重复.");
				}
			}
		}
	}

	private SysActionLog saveLog() {
		SysActionLog log = getCurrentActionLog();
		log.setDealCode(DealCode.MERCHANT_DISCOUNT);
		return log;
	}
}
