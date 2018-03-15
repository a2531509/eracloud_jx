<%@page import="com.erp.util.Constants"%>
<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
	var globalCardInfo;
	var cardinfo;
	$(function(){



		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		
		$("#dg").datagrid({
			url:"cardService/cardServiceAction!bhkzzRegisterQuery.action",
			fit:true,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			fitColumns:true,
			toolbar:"#tb",
			frozenColumns:[[
				{field:'',checkbox:true},
				{field:'CUSTOMER_ID',title:'客户编号',width:parseInt($(this).width() * 0.07)},
				{field:'NAME',title:'姓名',width:parseInt($(this).width() * 0.06)},
				{field:'CERT_TYPE',title:'证件类型',width:parseInt($(this).width() * 0.06), formatter:function(v){
					if(v == 1){
						return "身份证";
					} else if(v == 2){
						return "户口簿";
					} else if(v == 3){
						return "军官证";
					} else if(v == 4){
						return "护照";
					} else if(v == 5){
						return "户籍证明";
					} else if(v == 6){
						return "其它";
					}
				}},
				{field:'CERT_NO',title:'证件号码',width:parseInt($(this).width() * 0.12)},
				{field:'CARD_TYPE',title:'卡类型',width:parseInt($(this).width() * 0.06), formatter:function(v){
					if(v == <%=Constants.CARD_TYPE_QGN%>){
						return "全功能卡";
					} else if(v == <%=Constants.CARD_TYPE_SMZK%>){
						return "金融市民卡";
					}
					return v;
				}},
				{field:'CARD_NO',title:'卡号',width:parseInt($(this).width() * 0.13)},
				{field:'CARD_STATE',title:'卡状态',width:parseInt($(this).width() * 0.04), formatter:function(v){
					if(v == <%=Constants.CARD_STATE_ZC%>){
						return "<span style='color:green'>正常</span>";
					} else if(v == <%=Constants.CARD_STATE_GS%>){
						return "挂失";
					} else if(v == <%=Constants.CARD_STATE_SD%>){
						return "锁定";
					} else if(v == <%=Constants.CARD_STATE_WQY%>){
						return "未启用";
					} else if(v == <%=Constants.CARD_STATE_YGS%>){
						return "临时挂失";
					} else if(v == <%=Constants.CARD_STATE_ZX%>){
						return "<span style='color:red'>注销</span>";
					}
					return v;
				}},
				{field:'CANCEL_REASON',title:'注销原因',width:parseInt($(this).width() * 0.05), formatter:function(v){
					if(v == 1){
						return "换卡";
					} else if(v == 2){
						return "补卡";
					} else {
						return "其它";
					}
					return v;
				}}
			]],
			columns:[[
				{field:'QB_BAL',title:'钱包账户余额', formatter:function(v){
					return $.foramtMoney(Number(v).div100(0));
				}},
				{field:'QB_BAL_RSLT',title:'余额是否已处理', formatter:function(v){
					if(v == 0){
						return "<span style='color:orange'>否</span>";
					} else {
						return "<span style='color:black'>是</span>";
					}
				}},
				{field:'REGISTER_STATE',title:'登记状态', formatter:function(v){
					if(v == "0"){
						return "<span style='color:orange'>已登记</span>";
					} else if(v == "1"){
						return "<span style='color:green'>已处理</span>";
					} else {
						return "<span style='color:red'>未登记</span>";
					}
				}},
				{field:'REGISTER_BRCH_ID',title:'登记网点'},
				{field:'REGISTER_USER_ID',title:'登记柜员'},
				{field:'REGISTER_DATE',title:'登记时间'},
				{field:'DEAL_NO',title:'登记业务流水'}
			]],
			onLoadSuccess:function(data){
	           	 if(data.status != 0){
	           		 $.messager.alert('系统消息',data.errMsg,'error');
	           	 }
           	},
           	onBeforeLoad:function(para){
           		if(!para || !para.query){
           			return false;
           		}
           	},
           	onSelect:function(index, row){
           		$("#totalAmt").val($.foramtMoney(Number(row.QB_BAL).div100()));
           	}
		})
	})
	
	function readCard(){
		$("#form").form("reset");
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		globalCardInfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(globalCardInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + globalCardInfo["errMsg"],"error");
			return;
		}
		$("#cardNo").val(dealNull(globalCardInfo["card_No"]));
		$("#cardTrCount").val(globalCardInfo["recharge_Tr_Count"]);
		$("#cardAmt").val((parseFloat(isNaN(globalCardInfo["wallet_Amt"]) ? 0 : globalCardInfo["wallet_Amt"])/100).toFixed(2));
		query();
	}
	
	function query(){
		var cardNo = $("#cardNo").val();
		if(!cardNo){
			jAlert("卡号不能为空！", "warning");
			return;
		}
		
		$("#dg").datagrid("load", {
			cardNo:cardNo,
			query:true
		});
	}
	
	function regist(){
		var selection = $("#dg").datagrid("getSelected");
		if(!selection){
			jAlert("请选择一张卡片进行登记！", "warning");
			return;
		} else if (selection.CARD_STATE != <%=Constants.CARD_STATE_ZX%>){
			jAlert("卡片不是注销状态，不能登记！", "warning");
			return;
		} else if (selection.QB_BAL_RSLT != 0){
			jAlert("卡片钱包账户余额【已处理】，不能登记！", "warning");
			return;
		} else if (selection.REGISTER_STATE == "0" || selection.REGISTER_STATE == "1"){
			jAlert("卡片已登记，不能重复登记！", "warning");
			return;
		}
		
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		$.post("cardService/cardServiceAction!bhkzzRegister.action", {
			cardNo:selection.CARD_NO
		}, function(data){
			$.messager.progress("close");
			if(data.status != 1){
				jAlert("卡片登记成功！", "info", function(){
					query();
				});
			} else {
				jAlert("卡片登记失败，" + data.errMsg);
			}
		}, "json");
	}
	
	function bhkzz(){
		var selection = $("#dg").datagrid("getSelected");
		if(!selection){
			jAlert("请选择一张已登记卡片进行转钱包操作！", "warning");
			return;
		} else if (selection.REGISTER_STATE == ""){
			jAlert("卡片未登记，不能进行转钱包操作！", "warning");
			return;
		} else if (selection.QB_BAL_RSLT != 0){
			jAlert("卡片钱包账户余额处理结果【已处理】，不能进行转钱包操作！", "warning");
			return;
		}
		
		// 检查日期
		var now = new Date();
		var registerDate = new Date(Date.parse(selection.REGISTER_DATE.replace(/-/g,"/")));
		registerDate.addDays(7);
		var backDate = registerDate.format("yyyy-MM-dd");
		var nowDate = now.format("yyyy-MM-dd");
		if(backDate > nowDate){
			jAlert("未到账户返还日期，请在登记 7 天后再进行转钱包操作！", "warning");
			return;
		}
		
		var oldCardNo = selection.CARD_NO;
		var newCardNo = $("#cardNo").val();
		$.messager.confirm("系统消息","您确定要进行换卡转钱包吗？" + "<br/>转账总金额：" + $("#totalAmt").val(), function(is){
			if(is){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.post("cardService/cardServiceAction!saveBhkZzBadCard.action?" + $("#form2").serialize()+ "&rec.oldCardNo=" + oldCardNo + "&rec.cardNo=" + newCardNo + "&cardAmt=" + $("#cardAmt").val() + "&dealNo2=" + selection.DEAL_NO, function(data,status){
					if(status == "success"){
						if(data.status == "0"){
							$.messager.progress("close");
							$("#dealNo").val(data.dealNo);
							$.messager.progress({text:"正在写卡，请稍后...."});
							write_card(data.writecarddata);
						}else{
							$.messager.progress("close");
							$.messager.alert("系统消息",data.msg,"error");
						}
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","请求出现错误，请稍后重试！","error");
					}
				},"json").error(function(){
					$.messager.progress("close");
					$.messager.alert("系统消息","请求出现错误，请稍后重试！","error");
				});
			}
		});
	}
	function write_card(writecarddata){
		cardinfo = getcardinfo();
		if(judgeReadCardOk(cardinfo)){
			cycleNum0 = 0;
			wirtecard_recharge($("#cardNo").val(),writecarddata);
			cardinfo = getcardinfo();
			if(judgeReadCardOk(cardinfo)){
				if(Number(cardinfo["wallet_Amt"]) == getAmt()){
					$.messager.progress("close");
					$.messager.progress({text:"写卡成功，正在确认，请稍候..."});
					saveBhkZzConfirm();
				}else{
					cycleNum1++;
					if(cycleNum1 >= finalcyclenum){
						$.messager.progress("close");
						$.messager.progress({text:"写卡失败，正在撤销，请稍候..."});
						saveBhkZzCancel();
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","换卡转钱包写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！","error",function(){
							$.messager.progress({text : "正在进行转账，请稍后...."});
							write_card(writecarddata);
						});
					}
				}
			}else{
				write_card_next(writecarddata);
			}
		}else{
			cycleNum0++;
			if(cycleNum0 >= finalcyclenum){
				saveBhkZzCancel();
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡前获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！0" + cycleNum1 ,"error",function(){
					$.messager.progress({text : "正在进行转账，请稍后...."});
					write_card(writecarddata);
				});
			}
		}
	}
	function write_card_next(writecarddata){
		cardinfo = getcardinfo();
		if(judgeReadCardOk(cardinfo)){
			cycleNum2 = 0;
			if(Number(cardinfo["wallet_Amt"]) == (Number($("#cardAmt").val()).mul100() + Number($("#totalAmt").val()).mul100())){
				saveBhkZzConfirm();
			}else{
				cycleNum1++;
				if(cycleNum1 >= finalcyclenum){
					saveBhkZzCancel();
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","换卡转钱包写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！","error",function(){
						$.messager.progress({text : "正在进行转账，请稍后...."});
						write_card(writecarddata);
					});
				}
			}
		}else{
			cycleNum2++;
			if(cycleNum2 >= finalcyclenum){
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡后获取卡片信息出现错误，请再次读卡确认是否写卡成功，并人工处理【灰记录】！","error",function(){
					$.messager.progress({text : "正在加载，请稍后...."});
					window.history.go(0);
				});
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡后获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！","error",function(){
					$.messager.progress({text : "正在进行换卡转钱包，请稍后...."});
					write_card_next(writecarddata);
				});
			}
		}
	}
	function saveBhkZzCancel(){
		$.post("cardService/cardServiceAction!saveBhkZzCz.action",{dealNo:$("#dealNo").val()},function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(data.status == "0"){
					$.messager.alert("系统消息","换卡转钱包出现错误，请重新转账！","error",function(){
						$.messager.progress({text : "正在进行加载，请稍后...."});
						window.history.go(0);
					});
				}else{
					$.messager.alert("系统消息","换卡转钱包出现错误，冲正出现错误：" + data.msg + "，请人工取消【灰记录】！","error",function(){
						$.messager.progress({text : "正在进行加载，请稍后...."});
						window.history.go(0);
					});
				}
			}else{
				$.messager.alert("系统消息","换卡转钱包出现错误，冲正出现错误，请人工取消【灰记录】！","error",function(){
					$.messager.progress({text:"正在进行加载，请稍后...."});
					window.history.go(0);
				});
			}
		},"json").error(function(){
			$.messager.progress("close");
			$.messager.alert("系统消息","换卡转钱包出现错误，冲正出现错误，请人工取消【灰记录】！","error",function(){
				$.messager.progress({text : "正在进行加载，请稍后...."});
				window.history.go(0);
			});
		});
	}
	function saveBhkZzConfirm(){
		$.post("cardService/cardServiceAction!saveBhkZzConfirm.action",{dealNo:$("#dealNo").val()},function(data,status){
			if(status == "success"){
				$.messager.progress("close");
				if(data.status == "0"){
					showReport("换卡转钱包",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				}else{
					$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误：" + data.msg + "，请在打印凭证后人工确认【灰记录】！","error",function(){
						showReport("换卡转钱包",$("#dealNo").val(),function(){
							window.history.go(0);
						});
					});
				}
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误，请在打印凭证后人工确认【灰记录】！","error",function(){
					showReport("换卡转钱包",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				});
			}		
		},"json").error(function(){
			if($("#dealNo").val() != ""){
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误，请在打印凭证后人工确认【灰记录】！","error",function(){
					showReport("换卡转钱包",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				});
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误，请人工确认【灰记录】！","error",function(){
					$.messager.progress({text : "正在进行加载，请稍后...."});
					window.location.href = window.location.href + "?mm_=" + Math.random();
				});
			}
		});
	}
	function judgeReadCardOk(obj){
		if(obj["card_No"] == ""){
			return false;
		}
		if(obj["card_No"] == undefined){
			return false;
		}
		if(typeof(obj["card_No"]) == "undefined"){
			return false;
		}
		if(obj["card_No"] == "undefined"){
			return false;
		}
		if(obj["card_No"] != $("#cardNo").val()){
			return false;
		}
		return true;
	}
	function getAmt(){
		return (Number(Number($("#cardAmt").val()).mul100()) + Number(Number($("#totalAmt").val()).mul100()));
	}
	function readIdCard2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}


    function chkdj(obj){
	    if(obj.checked){{}
            $("#regist").show();
		}else{
            $("#regist").hide();
		}
    }

    function chkzqb(obj){
        if(obj.checked){{}
            $("#bhkzz").show();
        }else{
            $("#bhkzz").hide();
        }
    }
</script>
<n:initpage>
	<n:north title="进行坏卡换卡转钱包登记，转钱包操作" />
	<n:center>
		<div id="tb" class="datagrid-toolbar" data-options="border:false">
			<form id="form" method="post">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">（<span style="color:red;">新卡</span>）卡号:</td>
						<td class="tableright">
							<input id="cardNo" name="cardNo" class="textinput">
						</td>
						<td class="tableleft">卡内余额：</td>
						<td class="tableright"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" readonly="readonly"/></td>
						<td class="tableright">
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="hkzzBadCardDj">
								<a id="regist"  data-options="plain:false,iconCls:'icon-edit'" href="javascript:void(0);" class="easyui-linkbutton" onclick="regist()">登记</a>
							</shiro:hasPermission >
							<shiro:hasPermission name="hkzzBadCardZq">
								<a id="bhkzz" data-options="plain:false,iconCls:'icon-dzqbcz'" href="javascript:void(0);" class="easyui-linkbutton" onclick="bhkzz()">转钱包</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="卡片信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:160px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
		<div style="width:100%;height:100%">
			<form id="form2" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
				<input name="rec.cardTrCount" id="cardTrCount" value="0" type="hidden" />
				<input name="dealNo" id="dealNo" type="hidden" />
				<table class="tablegrid" style="width:100%;">
					<tr style="border: none">
						<td colspan="6" style="border: none">
							<h3 class="subtitle">转账信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">转账总金额：</th>
						<td class="tableright" colspan="5"><input name="totalAmt" id="totalAmt" value="0" class="textinput easyui-validatebox" type="text" required="required"  readonly="readonly"/><span style="color:red;margin-left:10px;">单位：元</span></td>
					</tr>
					<tr style="border: none">
						<td colspan="6" style="border: none">
							<h3 class="subtitle">代理人信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18"/></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
					</tr>
					<tr>
				 		<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11" /></td>
						<td class="tableright" colspan="4">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
						</td>
					</tr>
			   </table>
		    </form>	
	    </div>		
    </div>
</n:initpage>