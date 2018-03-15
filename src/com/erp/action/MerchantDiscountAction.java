package com.erp.action;

import java.util.List;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.erp.exception.CommonException;
import com.erp.model.AccKindConfig;
import com.erp.model.BaseMerchant;
import com.erp.model.MerchantDiscount;
import com.erp.service.MerchantDiscountService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 
 * @author Yueh
 *
 */
@Namespace("/merchant")
@Action(value = "merchantDiscountAction")
@Results({ @Result(name = "merchantDiscountAdd&EditPage", location = "/jsp/merchant/merchantDiscountAdd&EditPage.jsp") })
public class MerchantDiscountAction extends BaseAction {
	private static final long serialVersionUID = 1L;

	private MerchantDiscountService merchantDiscountService;

	private MerchantDiscount discount = new MerchantDiscount();
	private BaseMerchant merchant = new BaseMerchant();

	private String order;
	private String sort;
	private String model = "";

	public String getMerchantDiscounts() {
		try {
			String sql = "select id, d.merchant_id, m.merchant_name, acc_kind, discount, "
					+ "(select acc_name from acc_kind_config where acc_kind = d.acc_kind)acc_name, "
					+ "decode(discount_type, '1', '月', '2', '周', '3', '固定日')discount_type, "
					+ "to_char(startdate, 'yyyy-mm-dd')startdate, insert_user_id, discount_txt, "
					+ "to_char(insert_date, 'yyyy-mm-dd hh24:mi:ss')insert_date, state, d.note "
					+ "from BASE_MERCHANT_DISCOUNT d join base_merchant m on d.merchant_id = m.merchant_id "
					+ "where 1 = 1";
			if (!Tools.processNull(merchant.getMerchantId()).equals("")) {
				sql += "and d.merchant_id = " + discount.getMerchantId();
			}

			if (!Tools.processNull(merchant.getMerchantName()).equals("")) {
				sql += "and m.merchant_name like '%"
						+ merchant.getMerchantName() + "%'";
			}

			if (!Tools.processNull(discount.getState()).equals("")) {
				sql += "and d.state = '" + discount.getState() + "'";
			}

			if (!Tools.processNull(sort).equals("")) {
				sql += " order by " + sort;

				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			}

			Page data = merchantDiscountService.pagingQuery(sql.toString(),
					page, rows);

			if (data == null || data.getTotalCount() == 0) {
				throw new CommonException("找不到记录.");
			}

			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", "获取数据失败, " + e.getMessage());
		}
		return JSONOBJ;
	}

	public String addDiscount() {
		try {
			merchantDiscountService.addMerchantDiscount(discount);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String modifyDiscount() {
		try {
			merchantDiscountService.modifyMerchantDiscount(discount);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String checkDiscount() {
		try {
			merchantDiscountService.saveCheckMerchantDiscount(discount);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String cancelDiscount() {
		try {
			merchantDiscountService.saveCancelMerchantDiscount(discount);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String addDiscountPage() {
		model = "add";
		return "merchantDiscountAdd&EditPage";
	}

	@SuppressWarnings("unchecked")
	public String getAccKind() {
		try {
			List<AccKindConfig> accKinds = merchantDiscountService
					.findByHql("from AccKindConfig where accKindState = '"
							+ Constants.STATE_ZC
							+ "' and accKind in(select id.accKind from PayMerchantAcctype where id.merchantId = '"
							+ merchant.getMerchantId() + "')");

			AccKindConfig accKind2 = new AccKindConfig();
			accKind2.setAccName("请选择");
			accKind2.setAccKind("");
			accKinds.add(0, accKind2);
			OutputJson(accKinds);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String editDiscountPage() {
		model = "edit";

		discount = (MerchantDiscount) merchantDiscountService
				.findOnlyRowByHql("from MerchantDiscount where id = "
						+ discount.getId());

		merchant = (BaseMerchant) merchantDiscountService
				.findOnlyRowByHql("from BaseMerchant where merchantId = '"
						+ discount.getMerchantId() + "'");

		return "merchantDiscountAdd&EditPage";
	}

	// TODO

	public MerchantDiscountService getMerchantDiscountService() {
		return merchantDiscountService;
	}

	public void setMerchantDiscountService(
			MerchantDiscountService merchantDiscountService) {
		this.merchantDiscountService = merchantDiscountService;
	}

	public MerchantDiscount getDiscount() {
		return discount;
	}

	public void setDiscount(MerchantDiscount discount) {
		this.discount = discount;
	}

	public BaseMerchant getMerchant() {
		return merchant;
	}

	public void setMerchant(BaseMerchant merchant) {
		this.merchant = merchant;
	}

	public String getOrder() {
		return order;
	}

	public void setOrder(String order) {
		this.order = order;
	}

	public String getSort() {
		return sort;
	}

	public void setSort(String sort) {
		this.sort = sort;
	}

	public String getModel() {
		return model;
	}

	public void setModel(String model) {
		this.model = model;
	}

}
