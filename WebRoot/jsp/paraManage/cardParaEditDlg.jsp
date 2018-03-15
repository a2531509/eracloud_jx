<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>   
<style>
</style>
<script type="text/javascript">

	//金额里面特殊字符的验证以及金额是否大于0
	function checkBalance(str){
		var regsc = /^([^`=?%#!'\"\,\;:\\<>\u00b7\u00d7\u2014\u2018\u2019\u201c\u201d\u2026\u3001\u3002\u300a\u300b\u300e\u300f\u3010\u3011\uff01\uff08\uff09\uff0c\uff1a\uff1b\uff1f])*$/; //特殊字符串
		var regeng = /^[^a-zA-Z]*$/; //英文字符
		var regchn = /^[^\u4E00-\u9FFF]*$/; //中文汉字
		if(str.match(regsc)==null) return "不能包含特殊字符";
		if(str.match(regeng)==null) return "不能包含英文字符";
		if(str.match(regchn)==null) return "不能包含中文汉字";
		return true;
	}
	
	$(function() {
		if($("#cardType").val()!=""){
			$("input").each(function(){
		        $(this).attr("readonly","readonly");
		    });
		}else{
			$(".texthu").each(function(){
		        $(this).css("display","none");
		    });
		}
		$("#form").form({
			url :"cardParaManage/cardConfigAction!saveCardParaConfig.action",
			data: $('#form').serialize(),
			onSubmit : function(param) {
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
			},
			success:function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					$dg.datagrid("reload");
					$.modalDialog.openner.datagrid('reload');
					$.modalDialog.handler.dialog('close');
				}else{
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			}
		});
		
	});
	
	function validRmb(obj){
        var v = obj.value;
        var exp = /^\d*(\.?\d{0,2})?$/g;
        if(!exp.test(v)){
            if(isNaN(v) && v.indexOf('..') <= -1){
                obj.value = v.replace(/[^\d.]/g, "").replace(/^\./g, "").replace(/\.{2,}/g, ".").replace(".", "$#$").replace(/\./g, "").replace("$#$", ".").replace(/^(\-)*(\d+)\.(\d\d).*$/, '$1$2.$3');
            }else{
                obj.value = v.substring(0,v.length - 1);
            }
        }
    } 
	
	function changenoread(obj,obj1){
		if($(obj1).attr("checked")){
			$(obj).combo('readonly', false);
		}else{
			$(obj).combo('readonly', true);
		}
	}
	
	function changetextnoread(obj,obj1){
		if($(obj1).attr("checked")){
			$(obj).removeAttr("readonly");
		}else{
			$(obj).attr("readonly","readonly");
		}
		
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding:0px;">
		<form id="form" method="post">
			<h3 class="subtitle">卡参数信息</h3>
				<input name="editOrAddFlag" id="editOrAddFlag" value="${editOrAddFlag}"   type="hidden"/>
				<input name="config.cardName" id="cardName" value="${config.cardName}"   type="hidden"/>
				<input name="config.stkCode" id="stkCode" value="${config.stkCode}"  type="hidden"/>
				<input name="config.ordNo" id="ordNo" value="${config.ordNo}"  type="hidden"/>
				<input name="config.cardTypeState" id="cardTypeState"  value="${config.cardTypeState}"  type="hidden"/>
				<input name="config.onsiteMake" id="onsiteMake" value="${config.onsiteMake}"  type="hidden"/>
				<input name="config.chgNameFlag" id="chgNameFlag" value="${config.chgNameFlag}"  type="hidden"/>
				<input name="config.structMainType" id="structMainType" value="${config.structMainType}"  type="hidden"/>
				<input name="config.structChildType" id="structChildType" value="${config.structChildType}"  type="hidden"/>
				<input name="config.faceVal" id="faceVal" value="${config.faceVal}"  type="hidden"/>
				 <table class="tablegrid"style="width:100%">
					 <tr>
					 	<th class="tableleft">卡类型：</th>
						<td class="tableright">
							<input name="config.cardType" id="cardType" value="${config.cardType}"  class="easyui-combobox" style="width:179px;" data-options="
                                valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '100',
                                    value: '全功能卡'
                                }]" />
						</td>
						<th class="tableleft">卡大类：</th>
						<td class="tableright">
							<input name="config.cardTypeCatalog" id="cardTypeCatalog" value="${config.cardTypeCatalog}"  class="easyui-combobox" style="width:179px;" data-options="
                                valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '01',
                                    value: '全功能卡'
                                },{
                                    label: '02',
                                    value: '记名个性'
                                },{
                                    label: '03',
                                    value: '记名非个性'
                                },{
                                    label: '05',
                                    value: '非记名'
                                },{
                                    label: '07',
                                    value: '半成品'
                                }]" />
						</td>
						<th class="tableleft">是否唯一持有：</th>
						<td class="tableright">
							<input name="config.only" id="only" value="${config.only}"  class="easyui-combobox" style="width:179px;" data-options="
                                valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#only"),this);'/></span>
						</td>
					</tr>
					<tr>
						<th class="tableleft">记名设置：</th>
						<td class="tableright">
							<input name="config.namedFlag"  id="namedFlag" value="${config.namedFlag}" class="easyui-combobox" style="width:179px;" data-options="
								 valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#namedFlag"),this);'/>
						</td>
						<th class="tableleft">卡面是否个性化：</th>
						<td class="tableright">
							<input name="config.facePersonal"  id="facePersonal" value="${config.facePersonal}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#facePersonal"),this);'/>
						</td>
						<th class="tableleft">卡内是否写个人信息：</th>
						<td class="tableright">
							<input name="config.inPersonal"  id="inPersonal" value="${config.inPersonal}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#inPersonal"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">是否准许挂失：</th>
						<td class="tableright">
							<input name="config.lssFlag"  id="lssFlag" value="${config.lssFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#lssFlag"),this);'/>
						</td>
						<th class="tableleft">是否能重用：</th>
						<td class="tableright">
							<input name="config.reuseFlag"  id="reuseFlag" value="${config.reuseFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#reuseFlag"),this);'/>
						</td>
						<th class="tableleft">是否允许注销赎回：</th>
						<td class="tableright">
							<input name="config.redeemFlag"  id="redeemFlag" value="${config.redeemFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#lssFlag"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">是否允许补卡：</th>
						<td class="tableright">
							<input name="config.reissueFlag"  id="reissueFlag" value="${config.reissueFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#reissueFlag"),this);'/>
						</td>
						<th class="tableleft">补卡卡号是否变化：</th>
						<td class="tableright">
							<input name="config.reCardnoFlag"  id="reCardnoFlag" value="${config.reCardnoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#reCardnoFlag"),this);'/>
						</td>
						<th class="tableleft">补卡第二芯片卡号是否变化：</th>
						<td class="tableright">
							<input name="config.reSubnoFlag"  id="reSubnoFlag" value="${config.reSubnoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#reSubnoFlag"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">补卡银行卡号是否变化：</th>
						<td class="tableright">
							<input name="config.reBanknoFlag"  id="reBanknoFlag" value="${config.reBanknoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#reBanknoFlag"),this);'/>
						</td>
						<th class="tableleft">补卡条形码是否变化：</th>
						<td class="tableright">
							<input name="config.reBarnoFlag"  id="reBarnoFlag" value="${config.reBarnoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#reBarnoFlag"),this);'/>
						</td>
						<th class="tableleft">是否允许换卡：</th>
						<td class="tableright">
							<input name="config.chgFlag"  id="chgFlag" value="${config.chgFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#chgFlag"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">换卡卡号是否变化：</th>
						<td class="tableright">
							<input name="config.chgCardnoFlag"  id="chgCardnoFlag" value="${config.chgCardnoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#chgCardnoFlag"),this);'/>
						</td>
						<th class="tableleft">换卡第二芯片卡号是否变化：</th>
						<td class="tableright">
							<input name="config.chgSubnoFlag"  id="chgSubnoFlag" value="${config.chgSubnoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#chgSubnoFlag"),this);'/>
						</td>
							<th class="tableleft">换卡银行卡号是否变化：</th>
						<td class="tableright">
							<input name="config.chgBanknoFlag"  id="chgBanknoFlag" value="${config.chgBanknoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#chgBanknoFlag"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">换卡条形码是否变化：</th>
						<td class="tableright">
							<input name="config.chgBarnoFlag"  id="chgBarnoFlag" value="${config.chgBarnoFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#chgBarnoFlag"),this);'/>
						</td>
						<th class="tableleft">是否按任务批量出入库：</th>
						<td class="tableright">
							<input name="config.taskInoutStk"  id="taskInoutStk" value="${config.taskInoutStk}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#taskInoutStk"),this);'/>
						</td>
						<th class="tableleft">生成密码环节：</th>
						<td class="tableright">
							<input name="config.pwdFlag"  id="pwdFlag" value="${config.pwdFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '不生成'
                                },{
                                    label: '1',
                                    value: '生成任务'
                                },{
                                    label: '1',
                                    value: '导出任务'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#pwdFlag"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">是否有明细：</th>
						<td class="tableright">
							<input name="config.lstFlag"  id="lstFlag" value="${config.lstFlag}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#lstFlag"),this);'/>
						</td>
						<th class="tableleft">主副卡标志：</th>
						<td class="tableright">
							<input name="config.isparent"  id="isparent" value="${config.isparent}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '默认'
                                },{
                                    label: '1',
                                    value: '副卡'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#isparent"),this);'/>
						</td>
						<th class="tableleft">主副卡是否联动：</th>
						<td class="tableright">
							<input name="config.glLss"  id="glLss" value="${config.glLss}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#glLss"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">卡片有效期年数：</th>
						<td class="tableright">
							<input name="config.cardValidityPeriod"  id="cardValidityPeriod" value="${config.cardValidityPeriod}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '10',
                                    value: '十年'
                                },{
                                    label: '20',
                                    value: '二十年'
                                },{
                                    label: '30',
                                    value: '三十年'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#cardValidityPeriod"),this);'/>
						</td>
						<th class="tableleft">个人卡或商户卡：</th>
						<td class="tableright">
							<input name="config.perOrBiz"  id="perOrBiz" value="${config.perOrBiz}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '个人'
                                },{
                                    label: '1',
                                    value: '商户'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#perOrBiz"),this);'/>
						</td>
						<th class="tableleft">是否准许代理销售：</th>
						<td class="tableright">
							<input name="config.agentSale"  id="agentSale" value="${config.agentSale}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#agentSale"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">钱包充值限额<span style="color:red"><span style="color:red">（分）</span></span>：</th>
						<td class="tableright">
							<input name="config.walletCaseRechgLmt"  id="walletCaseRechgLmt" value="${config.walletCaseRechgLmt}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"  type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#walletCaseRechgLmt"),this);'/>
						</td>
						<th class="tableleft">账户充值限额<span style="color:red">（分）</span>：</th>
						<td class="tableright">
							<input name="config.accCaseRechgLmt"  id="accCaseRechgLmt" value="${config.accCaseRechgLmt}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"   type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#accCaseRechgLmt"),this);'/>
						</td>
						<th class="tableleft">银行单次圈存限额<span style="color:red">（分）</span>：</th>
						<td class="tableright">
							<input name="config.bankRechgLmt"  id="bankRechgLmt" value="${config.bankRechgLmt}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"   type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#bankRechgLmt"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">现金充值最低限额<span style="color:red">（分）</span>：</th>
						<td class="tableright">
							<input name="config.cashRechgLow"  id="cashRechgLow" value="${config.cashRechgLow}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"  type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#cashRechgLow"),this);'/>
						</td>
						
						
						<th class="tableleft">工本费<span style="color:red">（分）</span>：</th>
						<td class="tableright">
							<input name="config.costFee"  id="costFee" value="${config.costFee}" class="textinput"  onkeyup="validRmb(this)" onkeydown="validRmb(this)"   type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#costFee"),this);'/>
						</td>
						<th class="tableleft">押金<span style="color:red">（分）</span>：</th>
						<td class="tableright">
							<input name="config.foregift"  id="foregift" value="${config.foregift}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"   type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#foregift"),this);'/>
						</td>
					</tr>
					
					<tr>
						<th class="tableleft">加急费<span style="color:red">（分）：</th>
						<td class="tableright">
							<input name="config.urgentFee"  id="urgentFee" value="${config.urgentFee}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"  type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#urgentFee"),this);'/>
						</td>
						<th class="tableleft">石否有库存：</th>
						<td class="tableright">
							<input name="config.isStock"  id="isStock" value="${config.isStock}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#isStock"),this);'/>
						</td>
						<th class="tableleft">补换卡是否转移应该：</th>
						<td class="tableright">
							<input name="config.isApp"  id="isApp" value="${config.isApp}" class="easyui-combobox"   style="width:179px;" data-options="
								valueField: 'label',
                                textField: 'value',
                                data: [{
                                    label: '',
                                    value: '请选择'
                                },{
                                    label: '0',
                                    value: '是'
                                },{
                                    label: '1',
                                    value: '否'
                                }]" /><span class="texthu"><input type="checkbox" onclick='changenoread($("#isApp"),this);'/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">钱包单笔充值限额<span style="color:red"><span style="color:red">（分）</span></span>：</th>
						<td class="tableright">
							<input name="config.walletOneAllowMax"  id="walletOneAllowMax" value="${config.walletOneAllowMax}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"  type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#walletOneAllowMax"),this);'/>
						</td>
						<th class="tableleft">账户单笔充值限额<span style="color:red">（分）</span>：</th>
						<td class="tableright" colspan="3">
							<input name="config.accOneAllowMax"  id="accOneAllowMax" value="${config.accOneAllowMax}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"   type="text" />
							<span class="texthu"><input type="checkbox" onclick='changetextnoread($("#accOneAllowMax"),this);'/>
						</td>
						
					</tr>
				 </table>
			</form>
	</div>
</div>